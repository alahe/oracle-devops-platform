-- ============================================================================
-- Oracle DevOps Platform — APEX Dev Hub Seed Data (SSOT from generate_dev_hub.py)
-- Target Schema: DEVHUB in db-proxy (FREEPDB1)
-- ============================================================================

SET DEFINE OFF;
SET ECHO OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT >>> [1/5] Sünkroniseerin DEVHUB_SERVICES kirjed...

MERGE INTO DEVHUB.DEVHUB_SERVICES t USING (SELECT 'APEX_WS' AS id FROM dual) s ON (t.SERVICE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SERVICE_NAME = 'Oracle APEX Workspace', t.CATEGORY = 'MIDDLEWARE', t.EXTERNAL_PORT = 8088,
  t.TARGET_URL = 'http://localhost:8088/ords/r/proxy/devhub/', t.HEALTH_URL = 'http://localhost:8088/ords/', t.WALLET_ALIAS = 'DB_PROXY_DEVHUB',
  t.DEFAULT_USER = 'DEVELOPER', t.ICON_CLASS = 'fa-cubes', t.SORT_ORDER = 1
WHEN NOT MATCHED THEN INSERT
  (SERVICE_ID, SERVICE_NAME, CATEGORY, EXTERNAL_PORT, TARGET_URL, HEALTH_URL, WALLET_ALIAS, DEFAULT_USER, ICON_CLASS, SORT_ORDER, IS_ACTIVE, LAST_STATUS)
  VALUES ('APEX_WS', 'Oracle APEX Workspace', 'MIDDLEWARE', 8088, 'http://localhost:8088/ords/r/proxy/devhub/', 'http://localhost:8088/ords/', 'DB_PROXY_DEVHUB', 'DEVELOPER', 'fa-cubes', 1, 'Y', 'UNKNOWN');

MERGE INTO DEVHUB.DEVHUB_SERVICES t USING (SELECT 'APEX_ADMIN' AS id FROM dual) s ON (t.SERVICE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SERVICE_NAME = 'APEX Administration Services', t.CATEGORY = 'MIDDLEWARE', t.EXTERNAL_PORT = 8088,
  t.TARGET_URL = 'http://localhost:8088/ords/apex_admin', t.HEALTH_URL = 'http://localhost:8088/ords/', t.WALLET_ALIAS = 'DB_PROXY_APEX_ADMIN',
  t.DEFAULT_USER = 'ADMIN', t.ICON_CLASS = 'fa-shield', t.SORT_ORDER = 2
WHEN NOT MATCHED THEN INSERT
  (SERVICE_ID, SERVICE_NAME, CATEGORY, EXTERNAL_PORT, TARGET_URL, HEALTH_URL, WALLET_ALIAS, DEFAULT_USER, ICON_CLASS, SORT_ORDER, IS_ACTIVE, LAST_STATUS)
  VALUES ('APEX_ADMIN', 'APEX Administration Services', 'MIDDLEWARE', 8088, 'http://localhost:8088/ords/apex_admin', 'http://localhost:8088/ords/', 'DB_PROXY_APEX_ADMIN', 'ADMIN', 'fa-shield', 2, 'Y', 'UNKNOWN');

MERGE INTO DEVHUB.DEVHUB_SERVICES t USING (SELECT 'SDW' AS id FROM dual) s ON (t.SERVICE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SERVICE_NAME = 'Database Actions (SQL Developer Web)', t.CATEGORY = 'DATABASE', t.EXTERNAL_PORT = 8088,
  t.TARGET_URL = 'http://localhost:8088/ords/proxy/sql-developer/', t.HEALTH_URL = 'http://localhost:8088/ords/', t.WALLET_ALIAS = 'DB_PROXY_DEVHUB',
  t.DEFAULT_USER = 'DEVHUB', t.ICON_CLASS = 'fa-database', t.SORT_ORDER = 3
WHEN NOT MATCHED THEN INSERT
  (SERVICE_ID, SERVICE_NAME, CATEGORY, EXTERNAL_PORT, TARGET_URL, HEALTH_URL, WALLET_ALIAS, DEFAULT_USER, ICON_CLASS, SORT_ORDER, IS_ACTIVE, LAST_STATUS)
  VALUES ('SDW', 'Database Actions (SQL Developer Web)', 'DATABASE', 8088, 'http://localhost:8088/ords/proxy/sql-developer/', 'http://localhost:8088/ords/', 'DB_PROXY_DEVHUB', 'DEVHUB', 'fa-database', 3, 'Y', 'UNKNOWN');

MERGE INTO DEVHUB.DEVHUB_SERVICES t USING (SELECT 'ORDS' AS id FROM dual) s ON (t.SERVICE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SERVICE_NAME = 'Oracle REST Data Services', t.CATEGORY = 'MIDDLEWARE', t.EXTERNAL_PORT = 8088,
  t.TARGET_URL = 'http://localhost:8088/ords/', t.HEALTH_URL = 'http://localhost:8088/ords/', t.WALLET_ALIAS = 'DB_PROXY_DEVHUB',
  t.DEFAULT_USER = 'ORDS_PUBLIC_USER', t.ICON_CLASS = 'fa-bolt', t.SORT_ORDER = 4
WHEN NOT MATCHED THEN INSERT
  (SERVICE_ID, SERVICE_NAME, CATEGORY, EXTERNAL_PORT, TARGET_URL, HEALTH_URL, WALLET_ALIAS, DEFAULT_USER, ICON_CLASS, SORT_ORDER, IS_ACTIVE, LAST_STATUS)
  VALUES ('ORDS', 'Oracle REST Data Services', 'MIDDLEWARE', 8088, 'http://localhost:8088/ords/', 'http://localhost:8088/ords/', 'DB_PROXY_DEVHUB', 'ORDS_PUBLIC_USER', 'fa-bolt', 4, 'Y', 'UNKNOWN');

MERGE INTO DEVHUB.DEVHUB_SERVICES t USING (SELECT 'PUBLISHER' AS id FROM dual) s ON (t.SERVICE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SERVICE_NAME = 'Analytics Publisher (Pixel-Perfect)', t.CATEGORY = 'REPORTING', t.EXTERNAL_PORT = 9502,
  t.TARGET_URL = 'http://localhost:9502/xmlpserver', t.HEALTH_URL = 'http://localhost:9502/xmlpserver', t.WALLET_ALIAS = 'APP_PUBLISHER_ADMIN',
  t.DEFAULT_USER = 'bipadministrator', t.ICON_CLASS = 'fa-file-chart-o', t.SORT_ORDER = 5
WHEN NOT MATCHED THEN INSERT
  (SERVICE_ID, SERVICE_NAME, CATEGORY, EXTERNAL_PORT, TARGET_URL, HEALTH_URL, WALLET_ALIAS, DEFAULT_USER, ICON_CLASS, SORT_ORDER, IS_ACTIVE, LAST_STATUS)
  VALUES ('PUBLISHER', 'Analytics Publisher (Pixel-Perfect)', 'REPORTING', 9502, 'http://localhost:9502/xmlpserver', 'http://localhost:9502/xmlpserver', 'APP_PUBLISHER_ADMIN', 'bipadministrator', 'fa-file-chart-o', 5, 'Y', 'UNKNOWN');

MERGE INTO DEVHUB.DEVHUB_SERVICES t USING (SELECT 'FORMS_RUN' AS id FROM dual) s ON (t.SERVICE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SERVICE_NAME = 'Oracle Forms 14c Runtime', t.CATEGORY = 'MIDDLEWARE', t.EXTERNAL_PORT = 9001,
  t.TARGET_URL = 'http://localhost:9001/forms/frmservlet', t.HEALTH_URL = 'http://localhost:9001/forms/frmservlet', t.WALLET_ALIAS = 'APP_FORMS_ADMIN',
  t.DEFAULT_USER = 'WLS_ADMIN', t.ICON_CLASS = 'fa-window-restore', t.SORT_ORDER = 6
WHEN NOT MATCHED THEN INSERT
  (SERVICE_ID, SERVICE_NAME, CATEGORY, EXTERNAL_PORT, TARGET_URL, HEALTH_URL, WALLET_ALIAS, DEFAULT_USER, ICON_CLASS, SORT_ORDER, IS_ACTIVE, LAST_STATUS)
  VALUES ('FORMS_RUN', 'Oracle Forms 14c Runtime', 'MIDDLEWARE', 9001, 'http://localhost:9001/forms/frmservlet', 'http://localhost:9001/forms/frmservlet', 'APP_FORMS_ADMIN', 'WLS_ADMIN', 'fa-window-restore', 6, 'Y', 'UNKNOWN');

MERGE INTO DEVHUB.DEVHUB_SERVICES t USING (SELECT 'FORMS_GUI' AS id FROM dual) s ON (t.SERVICE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SERVICE_NAME = 'Oracle Forms Builder (noVNC GUI)', t.CATEGORY = 'TOOLING', t.EXTERNAL_PORT = 6083,
  t.TARGET_URL = 'http://localhost:6083/vnc.html', t.HEALTH_URL = 'http://localhost:6083/', t.WALLET_ALIAS = 'APP_FORMS_ADMIN',
  t.DEFAULT_USER = 'developer', t.ICON_CLASS = 'fa-desktop', t.SORT_ORDER = 7
WHEN NOT MATCHED THEN INSERT
  (SERVICE_ID, SERVICE_NAME, CATEGORY, EXTERNAL_PORT, TARGET_URL, HEALTH_URL, WALLET_ALIAS, DEFAULT_USER, ICON_CLASS, SORT_ORDER, IS_ACTIVE, LAST_STATUS)
  VALUES ('FORMS_GUI', 'Oracle Forms Builder (noVNC GUI)', 'TOOLING', 6083, 'http://localhost:6083/vnc.html', 'http://localhost:6083/', 'APP_FORMS_ADMIN', 'developer', 'fa-desktop', 7, 'Y', 'UNKNOWN');

MERGE INTO DEVHUB.DEVHUB_SERVICES t USING (SELECT 'WEB_IDE' AS id FROM dual) s ON (t.SERVICE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SERVICE_NAME = 'Cloud Web IDE & VS Code Server', t.CATEGORY = 'TOOLING', t.EXTERNAL_PORT = 8090,
  t.TARGET_URL = 'http://localhost:8090/', t.HEALTH_URL = 'http://localhost:8090/', t.WALLET_ALIAS = 'WEB_IDE_ADMIN',
  t.DEFAULT_USER = 'developer', t.ICON_CLASS = 'fa-code', t.SORT_ORDER = 8
WHEN NOT MATCHED THEN INSERT
  (SERVICE_ID, SERVICE_NAME, CATEGORY, EXTERNAL_PORT, TARGET_URL, HEALTH_URL, WALLET_ALIAS, DEFAULT_USER, ICON_CLASS, SORT_ORDER, IS_ACTIVE, LAST_STATUS)
  VALUES ('WEB_IDE', 'Cloud Web IDE & VS Code Server', 'TOOLING', 8090, 'http://localhost:8090/', 'http://localhost:8090/', 'WEB_IDE_ADMIN', 'developer', 'fa-code', 8, 'Y', 'UNKNOWN');

PROMPT >>> [2/5] Sünkroniseerin DEVHUB_TOPOLOGY kirjed...

MERGE INTO DEVHUB.DEVHUB_TOPOLOGY t USING (SELECT 'HOST_ROOT' AS id FROM dual) s ON (t.NODE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.PARENT_NODE_ID = NULL, t.NODE_TYPE = 'HOST', t.NAME = 'Developer Workstation (Host)',
  t.DESCRIPTION = 'Lokaalne arendusmasin (macOS / Linux / WSL2)', t.PORT_MAPPING = 'All forwarded ports', t.ICON_CLASS = 'fa-desktop', t.SORT_ORDER = 1
WHEN NOT MATCHED THEN INSERT
  (NODE_ID, PARENT_NODE_ID, NODE_TYPE, NAME, DESCRIPTION, PORT_MAPPING, ICON_CLASS, SORT_ORDER)
  VALUES ('HOST_ROOT', NULL, 'HOST', 'Developer Workstation (Host)', 'Lokaalne arendusmasin (macOS / Linux / WSL2)', 'All forwarded ports', 'fa-desktop', 1);

MERGE INTO DEVHUB.DEVHUB_TOPOLOGY t USING (SELECT 'PODMAN_NET' AS id FROM dual) s ON (t.NODE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.PARENT_NODE_ID = 'HOST_ROOT', t.NODE_TYPE = 'NETWORK', t.NAME = 'Podman Container Network (oracle-network)',
  t.DESCRIPTION = 'Virtuaalne sildvõrk konteinerite vahel', t.PORT_MAPPING = 'Internal DNS & Bridge', t.ICON_CLASS = 'fa-sitemap', t.SORT_ORDER = 2
WHEN NOT MATCHED THEN INSERT
  (NODE_ID, PARENT_NODE_ID, NODE_TYPE, NAME, DESCRIPTION, PORT_MAPPING, ICON_CLASS, SORT_ORDER)
  VALUES ('PODMAN_NET', 'HOST_ROOT', 'NETWORK', 'Podman Container Network (oracle-network)', 'Virtuaalne sildvõrk konteinerite vahel', 'Internal DNS & Bridge', 'fa-sitemap', 2);

MERGE INTO DEVHUB.DEVHUB_TOPOLOGY t USING (SELECT 'DB_PROXY_NODE' AS id FROM dual) s ON (t.NODE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.PARENT_NODE_ID = 'PODMAN_NET', t.NODE_TYPE = 'CONTAINER', t.NAME = 'db-proxy (Oracle 23ai/26ai Free)',
  t.DESCRIPTION = 'APEX lüüs, SEPS Wallet ja Dev Hub andmebaas', t.PORT_MAPPING = '1532 -> 1521', t.ICON_CLASS = 'fa-database', t.SORT_ORDER = 3
WHEN NOT MATCHED THEN INSERT
  (NODE_ID, PARENT_NODE_ID, NODE_TYPE, NAME, DESCRIPTION, PORT_MAPPING, ICON_CLASS, SORT_ORDER)
  VALUES ('DB_PROXY_NODE', 'PODMAN_NET', 'CONTAINER', 'db-proxy (Oracle 23ai/26ai Free)', 'APEX lüüs, SEPS Wallet ja Dev Hub andmebaas', '1532 -> 1521', 'fa-database', 3);

MERGE INTO DEVHUB.DEVHUB_TOPOLOGY t USING (SELECT 'PDB_FREEPDB1' AS id FROM dual) s ON (t.NODE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.PARENT_NODE_ID = 'DB_PROXY_NODE', t.NODE_TYPE = 'PDB', t.NAME = 'FREEPDB1 (Pluggable Database)',
  t.DESCRIPTION = 'Aktiivne PDB konteiner APEXi ja DEVHUB skeemiga', t.PORT_MAPPING = 'Service: FREEPDB1', t.ICON_CLASS = 'fa-database-lock', t.SORT_ORDER = 4
WHEN NOT MATCHED THEN INSERT
  (NODE_ID, PARENT_NODE_ID, NODE_TYPE, NAME, DESCRIPTION, PORT_MAPPING, ICON_CLASS, SORT_ORDER)
  VALUES ('PDB_FREEPDB1', 'DB_PROXY_NODE', 'PDB', 'FREEPDB1 (Pluggable Database)', 'Aktiivne PDB konteiner APEXi ja DEVHUB skeemiga', 'Service: FREEPDB1', 'fa-database-lock', 4);

MERGE INTO DEVHUB.DEVHUB_TOPOLOGY t USING (SELECT 'SVC_DEVHUB' AS id FROM dual) s ON (t.NODE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.PARENT_NODE_ID = 'PDB_FREEPDB1', t.NODE_TYPE = 'SERVICE', t.NAME = 'Oracle APEX Dev Hub (App 101)',
  t.DESCRIPTION = 'Igapäevane DevOps Command Center', t.PORT_MAPPING = 'URL: /ords/r/proxy/devhub/', t.ICON_CLASS = 'fa-cubes', t.SORT_ORDER = 5
WHEN NOT MATCHED THEN INSERT
  (NODE_ID, PARENT_NODE_ID, NODE_TYPE, NAME, DESCRIPTION, PORT_MAPPING, ICON_CLASS, SORT_ORDER)
  VALUES ('SVC_DEVHUB', 'PDB_FREEPDB1', 'SERVICE', 'Oracle APEX Dev Hub (App 101)', 'Igapäevane DevOps Command Center', 'URL: /ords/r/proxy/devhub/', 'fa-cubes', 5);

MERGE INTO DEVHUB.DEVHUB_TOPOLOGY t USING (SELECT 'SVC_APEX_ENGINE' AS id FROM dual) s ON (t.NODE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.PARENT_NODE_ID = 'PDB_FREEPDB1', t.NODE_TYPE = 'SERVICE', t.NAME = 'Oracle APEX 26.1 Runtime',
  t.DESCRIPTION = 'APEX mootor ja rakenduste käituskiht', t.PORT_MAPPING = 'Internal DB Engine', t.ICON_CLASS = 'fa-gear', t.SORT_ORDER = 6
WHEN NOT MATCHED THEN INSERT
  (NODE_ID, PARENT_NODE_ID, NODE_TYPE, NAME, DESCRIPTION, PORT_MAPPING, ICON_CLASS, SORT_ORDER)
  VALUES ('SVC_APEX_ENGINE', 'PDB_FREEPDB1', 'SERVICE', 'Oracle APEX 26.1 Runtime', 'APEX mootor ja rakenduste käituskiht', 'Internal DB Engine', 'fa-gear', 6);

MERGE INTO DEVHUB.DEVHUB_TOPOLOGY t USING (SELECT 'APP_ORDS_NODE' AS id FROM dual) s ON (t.NODE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.PARENT_NODE_ID = 'PODMAN_NET', t.NODE_TYPE = 'CONTAINER', t.NAME = 'app-ords (Oracle REST Data Services)',
  t.DESCRIPTION = 'ORDS 26.2.2 veebiserver ja APEX gateway', t.PORT_MAPPING = '8088, 8448 -> 8088', t.ICON_CLASS = 'fa-server', t.SORT_ORDER = 7
WHEN NOT MATCHED THEN INSERT
  (NODE_ID, PARENT_NODE_ID, NODE_TYPE, NAME, DESCRIPTION, PORT_MAPPING, ICON_CLASS, SORT_ORDER)
  VALUES ('APP_ORDS_NODE', 'PODMAN_NET', 'CONTAINER', 'app-ords (Oracle REST Data Services)', 'ORDS 26.2.2 veebiserver ja APEX gateway', '8088, 8448 -> 8088', 'fa-server', 7);

MERGE INTO DEVHUB.DEVHUB_TOPOLOGY t USING (SELECT 'POOL_PROXY' AS id FROM dual) s ON (t.NODE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.PARENT_NODE_ID = 'APP_ORDS_NODE', t.NODE_TYPE = 'SERVICE', t.NAME = 'Proxy Connection Pool (/ords/proxy/)',
  t.DESCRIPTION = 'ORDS pool ühenduses db-proxy baasiga', t.PORT_MAPPING = 'JDBC Pool', t.ICON_CLASS = 'fa-exchange', t.SORT_ORDER = 8
WHEN NOT MATCHED THEN INSERT
  (NODE_ID, PARENT_NODE_ID, NODE_TYPE, NAME, DESCRIPTION, PORT_MAPPING, ICON_CLASS, SORT_ORDER)
  VALUES ('POOL_PROXY', 'APP_ORDS_NODE', 'SERVICE', 'Proxy Connection Pool (/ords/proxy/)', 'ORDS pool ühenduses db-proxy baasiga', 'JDBC Pool', 'fa-exchange', 8);

MERGE INTO DEVHUB.DEVHUB_TOPOLOGY t USING (SELECT 'APP_PUB_NODE' AS id FROM dual) s ON (t.NODE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.PARENT_NODE_ID = 'PODMAN_NET', t.NODE_TYPE = 'CONTAINER', t.NAME = 'app-publisher (Analytics Publisher)',
  t.DESCRIPTION = 'Pixel-Perfect aruandlusmootor ja REST API', t.PORT_MAPPING = '9502 -> 9502', t.ICON_CLASS = 'fa-file-chart-o', t.SORT_ORDER = 9
WHEN NOT MATCHED THEN INSERT
  (NODE_ID, PARENT_NODE_ID, NODE_TYPE, NAME, DESCRIPTION, PORT_MAPPING, ICON_CLASS, SORT_ORDER)
  VALUES ('APP_PUB_NODE', 'PODMAN_NET', 'CONTAINER', 'app-publisher (Analytics Publisher)', 'Pixel-Perfect aruandlusmootor ja REST API', '9502 -> 9502', 'fa-file-chart-o', 9);

MERGE INTO DEVHUB.DEVHUB_TOPOLOGY t USING (SELECT 'APP_FORMS_NODE' AS id FROM dual) s ON (t.NODE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.PARENT_NODE_ID = 'PODMAN_NET', t.NODE_TYPE = 'CONTAINER', t.NAME = 'app-forms (Oracle Forms 14c)',
  t.DESCRIPTION = 'Forms 14c käituskeskkond ja WebLogic', t.PORT_MAPPING = '9001 -> 9001', t.ICON_CLASS = 'fa-window-restore', t.SORT_ORDER = 10
WHEN NOT MATCHED THEN INSERT
  (NODE_ID, PARENT_NODE_ID, NODE_TYPE, NAME, DESCRIPTION, PORT_MAPPING, ICON_CLASS, SORT_ORDER)
  VALUES ('APP_FORMS_NODE', 'PODMAN_NET', 'CONTAINER', 'app-forms (Oracle Forms 14c)', 'Forms 14c käituskeskkond ja WebLogic', '9001 -> 9001', 'fa-window-restore', 10);

MERGE INTO DEVHUB.DEVHUB_TOPOLOGY t USING (SELECT 'APP_WEBIDE_NODE' AS id FROM dual) s ON (t.NODE_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.PARENT_NODE_ID = 'PODMAN_NET', t.NODE_TYPE = 'CONTAINER', t.NAME = 'web-ide-dev (VS Code Server)',
  t.DESCRIPTION = 'Veebipõhine arenduskeskkond SQLcl ja Git toega', t.PORT_MAPPING = '8090 -> 8443', t.ICON_CLASS = 'fa-code', t.SORT_ORDER = 11
WHEN NOT MATCHED THEN INSERT
  (NODE_ID, PARENT_NODE_ID, NODE_TYPE, NAME, DESCRIPTION, PORT_MAPPING, ICON_CLASS, SORT_ORDER)
  VALUES ('APP_WEBIDE_NODE', 'PODMAN_NET', 'CONTAINER', 'web-ide-dev (VS Code Server)', 'Veebipõhine arenduskeskkond SQLcl ja Git toega', '8090 -> 8443', 'fa-code', 11);

PROMPT >>> [3/5] Sünkroniseerin DEVHUB_BLUEPRINTS kirjed...

MERGE INTO DEVHUB.DEVHUB_BLUEPRINTS t USING (SELECT 'BP_0' AS id FROM dual) s ON (t.BLUEPRINT_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.TITLE = 'Blueprint #0', t.COMPOSE_FILE = '.env.0-default-proxy-ords', t.CATEGORY = 'CORE',
  t.DESCRIPTION = 'Architecture blueprint configuration #0.', t.SERVICES_INCLUDED = 'A, c, t, i, v, e,  , C, o, n, t, a, i, n, e, r, s', t.IS_BASE = 'N', t.SORT_ORDER = 0
WHEN NOT MATCHED THEN INSERT
  (BLUEPRINT_ID, TITLE, COMPOSE_FILE, CATEGORY, DESCRIPTION, SERVICES_INCLUDED, IS_BASE, SORT_ORDER)
  VALUES ('BP_0', 'Blueprint #0', '.env.0-default-proxy-ords', 'CORE', 'Architecture blueprint configuration #0.', 'A, c, t, i, v, e,  , C, o, n, t, a, i, n, e, r, s', 'N', 0);

MERGE INTO DEVHUB.DEVHUB_BLUEPRINTS t USING (SELECT 'BP_1' AS id FROM dual) s ON (t.BLUEPRINT_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.TITLE = 'Standalone ALISE DB (Core Base)', t.COMPOSE_FILE = '.env.1-standalone-alise-db', t.CATEGORY = 'CORE',
  t.DESCRIPTION = 'Dedicated custom application database holding business schemas, PL/SQL code, DDL/DML and internal APEX & ORDS.', t.SERVICES_INCLUDED = 'd, b, -, a, l, i, s, e, ,,  , a, p, p, -, o, r, d, s', t.IS_BASE = 'Y', t.SORT_ORDER = 1
WHEN NOT MATCHED THEN INSERT
  (BLUEPRINT_ID, TITLE, COMPOSE_FILE, CATEGORY, DESCRIPTION, SERVICES_INCLUDED, IS_BASE, SORT_ORDER)
  VALUES ('BP_1', 'Standalone ALISE DB (Core Base)', '.env.1-standalone-alise-db', 'CORE', 'Dedicated custom application database holding business schemas, PL/SQL code, DDL/DML and internal APEX & ORDS.', 'd, b, -, a, l, i, s, e, ,,  , a, p, p, -, o, r, d, s', 'Y', 1);

MERGE INTO DEVHUB.DEVHUB_BLUEPRINTS t USING (SELECT 'BP_10' AS id FROM dual) s ON (t.BLUEPRINT_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.TITLE = 'Oracle Autonomous Database Cloud (ADB)', t.COMPOSE_FILE = '.env.10-remote-ords', t.CATEGORY = 'CLOUD',
  t.DESCRIPTION = 'Oracle Autonomous Database (ADB Serverless) with preinstalled APEX and ORDS, zero-trust cloud mTLS wallet security, and central gateway integration.', t.SERVICES_INCLUDED = 'd, b, -, a, l, i, s, e, ,,  , a, p, p, -, o, r, d, s', t.IS_BASE = 'N', t.SORT_ORDER = 10
WHEN NOT MATCHED THEN INSERT
  (BLUEPRINT_ID, TITLE, COMPOSE_FILE, CATEGORY, DESCRIPTION, SERVICES_INCLUDED, IS_BASE, SORT_ORDER)
  VALUES ('BP_10', 'Oracle Autonomous Database Cloud (ADB)', '.env.10-remote-ords', 'CLOUD', 'Oracle Autonomous Database (ADB Serverless) with preinstalled APEX and ORDS, zero-trust cloud mTLS wallet security, and central gateway integration.', 'd, b, -, a, l, i, s, e, ,,  , a, p, p, -, o, r, d, s', 'N', 10);

MERGE INTO DEVHUB.DEVHUB_BLUEPRINTS t USING (SELECT 'BP_11' AS id FROM dual) s ON (t.BLUEPRINT_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.TITLE = 'Blueprint #11', t.COMPOSE_FILE = '.env.11-remote-publisher', t.CATEGORY = 'CORE',
  t.DESCRIPTION = 'Architecture blueprint configuration #11.', t.SERVICES_INCLUDED = 'A, c, t, i, v, e,  , C, o, n, t, a, i, n, e, r, s', t.IS_BASE = 'N', t.SORT_ORDER = 11
WHEN NOT MATCHED THEN INSERT
  (BLUEPRINT_ID, TITLE, COMPOSE_FILE, CATEGORY, DESCRIPTION, SERVICES_INCLUDED, IS_BASE, SORT_ORDER)
  VALUES ('BP_11', 'Blueprint #11', '.env.11-remote-publisher', 'CORE', 'Architecture blueprint configuration #11.', 'A, c, t, i, v, e,  , C, o, n, t, a, i, n, e, r, s', 'N', 11);

MERGE INTO DEVHUB.DEVHUB_BLUEPRINTS t USING (SELECT 'BP_2' AS id FROM dual) s ON (t.BLUEPRINT_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.TITLE = 'Standalone ORDS & Dev Hub (Core Gateway)', t.COMPOSE_FILE = '.env.2-standalone-proxy-db', t.CATEGORY = 'CORE',
  t.DESCRIPTION = 'Standalone ORDS gateway routing requests to remote or cloud databases with Dev Hub dashboard.', t.SERVICES_INCLUDED = 'a, p, p, -, o, r, d, s', t.IS_BASE = 'Y', t.SORT_ORDER = 2
WHEN NOT MATCHED THEN INSERT
  (BLUEPRINT_ID, TITLE, COMPOSE_FILE, CATEGORY, DESCRIPTION, SERVICES_INCLUDED, IS_BASE, SORT_ORDER)
  VALUES ('BP_2', 'Standalone ORDS & Dev Hub (Core Gateway)', '.env.2-standalone-proxy-db', 'CORE', 'Standalone ORDS gateway routing requests to remote or cloud databases with Dev Hub dashboard.', 'a, p, p, -, o, r, d, s', 'Y', 2);

MERGE INTO DEVHUB.DEVHUB_BLUEPRINTS t USING (SELECT 'BP_3' AS id FROM dual) s ON (t.BLUEPRINT_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.TITLE = 'Standalone Proxy DB & APEX SSO', t.COMPOSE_FILE = '.env.3-standalone-gvenzl-db', t.CATEGORY = 'ISOLATE',
  t.DESCRIPTION = 'APEX Proxy database running ORDS and APEX, serving as a secure gateway for REST APIs, Azure Entra ID, and Kafka.', t.SERVICES_INCLUDED = 'd, b, -, p, r, o, x, y, ,,  , a, p, p, -, o, r, d, s', t.IS_BASE = 'Y', t.SORT_ORDER = 3
WHEN NOT MATCHED THEN INSERT
  (BLUEPRINT_ID, TITLE, COMPOSE_FILE, CATEGORY, DESCRIPTION, SERVICES_INCLUDED, IS_BASE, SORT_ORDER)
  VALUES ('BP_3', 'Standalone Proxy DB & APEX SSO', '.env.3-standalone-gvenzl-db', 'ISOLATE', 'APEX Proxy database running ORDS and APEX, serving as a secure gateway for REST APIs, Azure Entra ID, and Kafka.', 'd, b, -, p, r, o, x, y, ,,  , a, p, p, -, o, r, d, s', 'Y', 3);

MERGE INTO DEVHUB.DEVHUB_BLUEPRINTS t USING (SELECT 'BP_4' AS id FROM dual) s ON (t.BLUEPRINT_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.TITLE = 'Standalone Web-IDE Workstation', t.COMPOSE_FILE = '.env.4-standalone-autonomous-db', t.CATEGORY = 'ISOLATE',
  t.DESCRIPTION = 'Browser-based VS Code Web IDE with Oracle SQL Developer extension, Antigravity, and local CI testing (act) for Remote/Cloud DBs.', t.SERVICES_INCLUDED = 'w, e, b, -, i, d, e, -, d, e, v', t.IS_BASE = 'N', t.SORT_ORDER = 4
WHEN NOT MATCHED THEN INSERT
  (BLUEPRINT_ID, TITLE, COMPOSE_FILE, CATEGORY, DESCRIPTION, SERVICES_INCLUDED, IS_BASE, SORT_ORDER)
  VALUES ('BP_4', 'Standalone Web-IDE Workstation', '.env.4-standalone-autonomous-db', 'ISOLATE', 'Browser-based VS Code Web IDE with Oracle SQL Developer extension, Antigravity, and local CI testing (act) for Remote/Cloud DBs.', 'w, e, b, -, i, d, e, -, d, e, v', 'N', 4);

MERGE INTO DEVHUB.DEVHUB_BLUEPRINTS t USING (SELECT 'BP_5' AS id FROM dual) s ON (t.BLUEPRINT_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.TITLE = 'Standalone Analytics Publisher', t.COMPOSE_FILE = '.env.5-standalone-publisher', t.CATEGORY = 'ISOLATE',
  t.DESCRIPTION = 'Oracle Analytics Publisher (Pixel-Perfect) with dedicated RCU infrastructure database (db-publisher) and central ORDS.', t.SERVICES_INCLUDED = 'd, b, -, p, u, b, l, i, s, h, e, r, ,,  , a, p, p, -, o, r, d, s, ,,  , a, p, p, -, p, u, b, l, i, s, h, e, r', t.IS_BASE = 'N', t.SORT_ORDER = 5
WHEN NOT MATCHED THEN INSERT
  (BLUEPRINT_ID, TITLE, COMPOSE_FILE, CATEGORY, DESCRIPTION, SERVICES_INCLUDED, IS_BASE, SORT_ORDER)
  VALUES ('BP_5', 'Standalone Analytics Publisher', '.env.5-standalone-publisher', 'ISOLATE', 'Oracle Analytics Publisher (Pixel-Perfect) with dedicated RCU infrastructure database (db-publisher) and central ORDS.', 'd, b, -, p, u, b, l, i, s, h, e, r, ,,  , a, p, p, -, o, r, d, s, ,,  , a, p, p, -, p, u, b, l, i, s, h, e, r', 'N', 5);

MERGE INTO DEVHUB.DEVHUB_BLUEPRINTS t USING (SELECT 'BP_6' AS id FROM dual) s ON (t.BLUEPRINT_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.TITLE = 'Standalone Publisher Designer Workstation', t.COMPOSE_FILE = '.env.6-standalone-forms', t.CATEGORY = 'ISOLATE',
  t.DESCRIPTION = 'Web-based MS Word & Oracle BI Publisher Desktop (Template Builder) via HTML5 noVNC (:6083) for Pixel-Perfect RTF design on Remote/Cloud Publisher.', t.SERVICES_INCLUDED = 'a, p, p, -, p, u, b, l, i, s, h, e, r, -, d, e, s, i, g, n, e, r', t.IS_BASE = 'N', t.SORT_ORDER = 6
WHEN NOT MATCHED THEN INSERT
  (BLUEPRINT_ID, TITLE, COMPOSE_FILE, CATEGORY, DESCRIPTION, SERVICES_INCLUDED, IS_BASE, SORT_ORDER)
  VALUES ('BP_6', 'Standalone Publisher Designer Workstation', '.env.6-standalone-forms', 'ISOLATE', 'Web-based MS Word & Oracle BI Publisher Desktop (Template Builder) via HTML5 noVNC (:6083) for Pixel-Perfect RTF design on Remote/Cloud Publisher.', 'a, p, p, -, p, u, b, l, i, s, h, e, r, -, d, e, s, i, g, n, e, r', 'N', 6);

MERGE INTO DEVHUB.DEVHUB_BLUEPRINTS t USING (SELECT 'BP_7' AS id FROM dual) s ON (t.BLUEPRINT_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.TITLE = 'Standalone Oracle Forms 14c', t.COMPOSE_FILE = '.env.7-consolidated-forms-publisher', t.CATEGORY = 'ISOLATE',
  t.DESCRIPTION = 'Oracle Forms 14c Services and HTML5 noVNC Forms Builder GUI with dedicated Forms RCU database (db-forms).', t.SERVICES_INCLUDED = 'd, b, -, f, o, r, m, s, ,,  , a, p, p, -, f, o, r, m, s', t.IS_BASE = 'N', t.SORT_ORDER = 7
WHEN NOT MATCHED THEN INSERT
  (BLUEPRINT_ID, TITLE, COMPOSE_FILE, CATEGORY, DESCRIPTION, SERVICES_INCLUDED, IS_BASE, SORT_ORDER)
  VALUES ('BP_7', 'Standalone Oracle Forms 14c', '.env.7-consolidated-forms-publisher', 'ISOLATE', 'Oracle Forms 14c Services and HTML5 noVNC Forms Builder GUI with dedicated Forms RCU database (db-forms).', 'd, b, -, f, o, r, m, s, ,,  , a, p, p, -, f, o, r, m, s', 'N', 7);

MERGE INTO DEVHUB.DEVHUB_BLUEPRINTS t USING (SELECT 'BP_8' AS id FROM dual) s ON (t.BLUEPRINT_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.TITLE = 'Consolidated Forms & Publisher Unified FMW', t.COMPOSE_FILE = '.env.8-standalone-web-ide', t.CATEGORY = 'COMBINED',
  t.DESCRIPTION = 'Unified WebLogic domain running both Forms 14c Services/Builder and Analytics Publisher on shared db-publisher RCU database with central ORDS.', t.SERVICES_INCLUDED = 'd, b, -, p, u, b, l, i, s, h, e, r, ,,  , a, p, p, -, o, r, d, s, ,,  , a, p, p, -, f, o, r, m, s, -, p, u, b, l, i, s, h, e, r', t.IS_BASE = 'N', t.SORT_ORDER = 8
WHEN NOT MATCHED THEN INSERT
  (BLUEPRINT_ID, TITLE, COMPOSE_FILE, CATEGORY, DESCRIPTION, SERVICES_INCLUDED, IS_BASE, SORT_ORDER)
  VALUES ('BP_8', 'Consolidated Forms & Publisher Unified FMW', '.env.8-standalone-web-ide', 'COMBINED', 'Unified WebLogic domain running both Forms 14c Services/Builder and Analytics Publisher on shared db-publisher RCU database with central ORDS.', 'd, b, -, p, u, b, l, i, s, h, e, r, ,,  , a, p, p, -, o, r, d, s, ,,  , a, p, p, -, f, o, r, m, s, -, p, u, b, l, i, s, h, e, r', 'N', 8);

MERGE INTO DEVHUB.DEVHUB_BLUEPRINTS t USING (SELECT 'BP_9' AS id FROM dual) s ON (t.BLUEPRINT_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.TITLE = 'Alternate Community Vendor DB (gvenzl)', t.COMPOSE_FILE = '.env.9-standalone-publisher-designer', t.CATEGORY = 'ISOLATE',
  t.DESCRIPTION = 'Standalone APEX & ORDS database running on Docker Hub community container image (gvenzl/oracle-free) for comparative benchmarking and fast security patch testing.', t.SERVICES_INCLUDED = 'd, b, -, a, l, i, s, e, ,,  , a, p, p, -, o, r, d, s', t.IS_BASE = 'N', t.SORT_ORDER = 9
WHEN NOT MATCHED THEN INSERT
  (BLUEPRINT_ID, TITLE, COMPOSE_FILE, CATEGORY, DESCRIPTION, SERVICES_INCLUDED, IS_BASE, SORT_ORDER)
  VALUES ('BP_9', 'Alternate Community Vendor DB (gvenzl)', '.env.9-standalone-publisher-designer', 'ISOLATE', 'Standalone APEX & ORDS database running on Docker Hub community container image (gvenzl/oracle-free) for comparative benchmarking and fast security patch testing.', 'd, b, -, a, l, i, s, e, ,,  , a, p, p, -, o, r, d, s', 'N', 9);

PROMPT >>> [4/5] Sünkroniseerin DEVHUB_DOC_INDEX kirjed...

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'publisher-template-builder' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'publisher-template-builder', t.TITLE_KEY = '📑 Publisher Desktop & Word Designer Guide', t.REL_PATH = 'docs/publisher-template-builder-guide.md', t.SORT_ORDER = 10
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('publisher-template-builder', 'publisher-template-builder', '📑 Publisher Desktop & Word Designer Guide', 'docs/publisher-template-builder-guide.md', 10);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'readme' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'readme', t.TITLE_KEY = '📖 Quick Start & Platform Overview', t.REL_PATH = 'README.md', t.SORT_ORDER = 20
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('readme', 'readme', '📖 Quick Start & Platform Overview', 'README.md', 20);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'quick-login' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'quick-login', t.TITLE_KEY = '🚀 Quick Login & Clipboard Guide', t.REL_PATH = 'docs/quick-login-guide.md', t.SORT_ORDER = 30
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('quick-login', 'quick-login', '🚀 Quick Login & Clipboard Guide', 'docs/quick-login-guide.md', 30);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'db-topology' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'db-topology', t.TITLE_KEY = '🏗️ Database Profiles & Topology', t.REL_PATH = 'docs/db-profiles-and-topology.md', t.SORT_ORDER = 40
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('db-topology', 'db-topology', '🏗️ Database Profiles & Topology', 'docs/db-profiles-and-topology.md', 40);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'forms-setup' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'forms-setup', t.TITLE_KEY = '📄 Oracle Forms 14c & Modernization', t.REL_PATH = 'docs/forms-setup.md', t.SORT_ORDER = 50
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('forms-setup', 'forms-setup', '📄 Oracle Forms 14c & Modernization', 'docs/forms-setup.md', 50);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'publisher-setup' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'publisher-setup', t.TITLE_KEY = '📊 Analytics Publisher (Pixel-Perfect)', t.REL_PATH = 'docs/publisher-setup.md', t.SORT_ORDER = 60
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('publisher-setup', 'publisher-setup', '📊 Analytics Publisher (Pixel-Perfect)', 'docs/publisher-setup.md', 60);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'security' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'security', t.TITLE_KEY = '🔐 Security, TLS & SEPS Wallet', t.REL_PATH = 'docs/turvalisus.md', t.SORT_ORDER = 70
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('security', 'security', '🔐 Security, TLS & SEPS Wallet', 'docs/turvalisus.md', 70);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'web-ide' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'web-ide', t.TITLE_KEY = '💻 Web IDE & Artifactory Setup', t.REL_PATH = 'docs/web-ide-artifactory.md', t.SORT_ORDER = 80
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('web-ide', 'web-ide', '💻 Web IDE & Artifactory Setup', 'docs/web-ide-artifactory.md', 80);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'apex-deploy' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'apex-deploy', t.TITLE_KEY = '📦 APEX Application CI/CD Deployment', t.REL_PATH = 'docs/apex-apps-deployment.md', t.SORT_ORDER = 90
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('apex-deploy', 'apex-deploy', '📦 APEX Application CI/CD Deployment', 'docs/apex-apps-deployment.md', 90);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'setup-workflow' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'setup-workflow', t.TITLE_KEY = '⚡ Setup-All Architecture & Metrics', t.REL_PATH = 'docs/setup-all-workflow.md', t.SORT_ORDER = 100
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('setup-workflow', 'setup-workflow', '⚡ Setup-All Architecture & Metrics', 'docs/setup-all-workflow.md', 100);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'future-plans' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'future-plans', t.TITLE_KEY = '🚀 Future Architecture Roadmap', t.REL_PATH = 'docs/future-plans.md', t.SORT_ORDER = 110
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('future-plans', 'future-plans', '🚀 Future Architecture Roadmap', 'docs/future-plans.md', 110);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'forms-to-apex' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'forms-to-apex', t.TITLE_KEY = '🚀 Forms-to-APEX Modernization Guide', t.REL_PATH = 'docs/forms-to-apex-migration-guide.md', t.SORT_ORDER = 120
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('forms-to-apex', 'forms-to-apex', '🚀 Forms-to-APEX Modernization Guide', 'docs/forms-to-apex-migration-guide.md', 120);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'blueprints-matrix' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'blueprints-matrix', t.TITLE_KEY = '📋 Architecture Blueprints Matrix', t.REL_PATH = 'config/blueprints/README.md', t.SORT_ORDER = 130
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('blueprints-matrix', 'blueprints-matrix', '📋 Architecture Blueprints Matrix', 'config/blueprints/README.md', 130);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'devops-lifecycle' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'devops-lifecycle', t.TITLE_KEY = '🔄 3-Tier Lifecycle (Images, Snapshots, Backups)', t.REL_PATH = 'docs/devops-lifecycle-guide.md', t.SORT_ORDER = 140
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('devops-lifecycle', 'devops-lifecycle', '🔄 3-Tier Lifecycle (Images, Snapshots, Backups)', 'docs/devops-lifecycle-guide.md', 140);

MERGE INTO DEVHUB.DEVHUB_DOC_INDEX t USING (SELECT 'image-switching' AS id FROM dual) s ON (t.DOC_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.SLUG = 'image-switching', t.TITLE_KEY = '🔄 Database Image Switching & Multi-Vendor Guide', t.REL_PATH = 'docs/database-image-switching-guide.md', t.SORT_ORDER = 150
WHEN NOT MATCHED THEN INSERT
  (DOC_ID, SLUG, TITLE_KEY, REL_PATH, SORT_ORDER)
  VALUES ('image-switching', 'image-switching', '🔄 Database Image Switching & Multi-Vendor Guide', 'docs/database-image-switching-guide.md', 150);

PROMPT >>> [5/5] Sünkroniseerin DEVHUB_COMMANDS kirjed...

MERGE INTO DEVHUB.DEVHUB_COMMANDS t USING (SELECT 'CMD_SETUP' AS id FROM dual) s ON (t.COMMAND_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.CATEGORY = 'LIFECYCLE', t.TITLE_KEY = 'Täispaigaldus ja käivitus', t.COMMAND_TEXT = './scripts/setup-all.sh -b 3',
  t.EXPLANATION = 'Käivitab täieliku paigaldusvoo (Proxy DB + ORDS + APEX Dev Hub)', t.SORT_ORDER = 10
WHEN NOT MATCHED THEN INSERT
  (COMMAND_ID, CATEGORY, TITLE_KEY, COMMAND_TEXT, EXPLANATION, SORT_ORDER)
  VALUES ('CMD_SETUP', 'LIFECYCLE', 'Täispaigaldus ja käivitus', './scripts/setup-all.sh -b 3', 'Käivitab täieliku paigaldusvoo (Proxy DB + ORDS + APEX Dev Hub)', 10);

MERGE INTO DEVHUB.DEVHUB_COMMANDS t USING (SELECT 'CMD_RESET' AS id FROM dual) s ON (t.COMMAND_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.CATEGORY = 'LIFECYCLE', t.TITLE_KEY = 'Täielik keskkonna nullimine', t.COMMAND_TEXT = './scripts/reset-all.sh',
  t.EXPLANATION = 'Peatab konteinerid ja eemaldab volüümid puhtaks uuestialustuseks', t.SORT_ORDER = 20
WHEN NOT MATCHED THEN INSERT
  (COMMAND_ID, CATEGORY, TITLE_KEY, COMMAND_TEXT, EXPLANATION, SORT_ORDER)
  VALUES ('CMD_RESET', 'LIFECYCLE', 'Täielik keskkonna nullimine', './scripts/reset-all.sh', 'Peatab konteinerid ja eemaldab volüümid puhtaks uuestialustuseks', 20);

MERGE INTO DEVHUB.DEVHUB_COMMANDS t USING (SELECT 'CMD_START' AS id FROM dual) s ON (t.COMMAND_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.CATEGORY = 'LIFECYCLE', t.TITLE_KEY = 'Konteinerite käivitamine', t.COMMAND_TEXT = './scripts/start-containers.sh -b 3',
  t.EXPLANATION = 'Käivitab Blueprint 3 konteinerid taustal', t.SORT_ORDER = 30
WHEN NOT MATCHED THEN INSERT
  (COMMAND_ID, CATEGORY, TITLE_KEY, COMMAND_TEXT, EXPLANATION, SORT_ORDER)
  VALUES ('CMD_START', 'LIFECYCLE', 'Konteinerite käivitamine', './scripts/start-containers.sh -b 3', 'Käivitab Blueprint 3 konteinerid taustal', 30);

MERGE INTO DEVHUB.DEVHUB_COMMANDS t USING (SELECT 'CMD_GET_PWD' AS id FROM dual) s ON (t.COMMAND_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.CATEGORY = 'SEPS', t.TITLE_KEY = 'SEPS Parooli lugemine mälust', t.COMMAND_TEXT = './scripts/get-password.sh DB_PROXY_DEVHUB',
  t.EXPLANATION = 'Kuvab SEPS Walletist turvaliselt dekrüpteeritud parooli', t.SORT_ORDER = 40
WHEN NOT MATCHED THEN INSERT
  (COMMAND_ID, CATEGORY, TITLE_KEY, COMMAND_TEXT, EXPLANATION, SORT_ORDER)
  VALUES ('CMD_GET_PWD', 'SEPS', 'SEPS Parooli lugemine mälust', './scripts/get-password.sh DB_PROXY_DEVHUB', 'Kuvab SEPS Walletist turvaliselt dekrüpteeritud parooli', 40);

MERGE INTO DEVHUB.DEVHUB_COMMANDS t USING (SELECT 'CMD_WALLET_CHK' AS id FROM dual) s ON (t.COMMAND_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.CATEGORY = 'SEPS', t.TITLE_KEY = 'Walleti ühenduste diagnostika', t.COMMAND_TEXT = './scripts/check-wallet.sh',
  t.EXPLANATION = 'Kontrollib kõiki SEPS Wallet aliaseid ja TNS seadistust', t.SORT_ORDER = 50
WHEN NOT MATCHED THEN INSERT
  (COMMAND_ID, CATEGORY, TITLE_KEY, COMMAND_TEXT, EXPLANATION, SORT_ORDER)
  VALUES ('CMD_WALLET_CHK', 'SEPS', 'Walleti ühenduste diagnostika', './scripts/check-wallet.sh', 'Kontrollib kõiki SEPS Wallet aliaseid ja TNS seadistust', 50);

MERGE INTO DEVHUB.DEVHUB_COMMANDS t USING (SELECT 'CMD_URL_CHK' AS id FROM dual) s ON (t.COMMAND_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.CATEGORY = 'DIAGNOSTICS', t.TITLE_KEY = 'Veebiteenuste tervisekontroll', t.COMMAND_TEXT = './scripts/check-urls.sh',
  t.EXPLANATION = 'Testib HTTP staatusekoode kõigil aktiivsetel veebiotspunktidel', t.SORT_ORDER = 60
WHEN NOT MATCHED THEN INSERT
  (COMMAND_ID, CATEGORY, TITLE_KEY, COMMAND_TEXT, EXPLANATION, SORT_ORDER)
  VALUES ('CMD_URL_CHK', 'DIAGNOSTICS', 'Veebiteenuste tervisekontroll', './scripts/check-urls.sh', 'Testib HTTP staatusekoode kõigil aktiivsetel veebiotspunktidel', 60);

MERGE INTO DEVHUB.DEVHUB_COMMANDS t USING (SELECT 'CMD_SQLCL' AS id FROM dual) s ON (t.COMMAND_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.CATEGORY = 'TOOLING', t.TITLE_KEY = 'SQLcl Käsurida Walletiga', t.COMMAND_TEXT = './scripts/sqlcl.sh /@DB_PROXY_DEVHUB',
  t.EXPLANATION = 'Avab SQLcl käsurea ilma parooli küsimata läbi Walleti', t.SORT_ORDER = 70
WHEN NOT MATCHED THEN INSERT
  (COMMAND_ID, CATEGORY, TITLE_KEY, COMMAND_TEXT, EXPLANATION, SORT_ORDER)
  VALUES ('CMD_SQLCL', 'TOOLING', 'SQLcl Käsurida Walletiga', './scripts/sqlcl.sh /@DB_PROXY_DEVHUB', 'Avab SQLcl käsurea ilma parooli küsimata läbi Walleti', 70);

MERGE INTO DEVHUB.DEVHUB_COMMANDS t USING (SELECT 'CMD_SNAP_RESTORE' AS id FROM dual) s ON (t.COMMAND_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.CATEGORY = 'SNAPSHOTS', t.TITLE_KEY = 'Golden Snapshot Taastamine', t.COMMAND_TEXT = './scripts/snapshots/restore-golden-snapshots.sh',
  t.EXPLANATION = 'Taastab andmebaasi kuldse hetktõmmise seisundisse ~15 sekundiga', t.SORT_ORDER = 80
WHEN NOT MATCHED THEN INSERT
  (COMMAND_ID, CATEGORY, TITLE_KEY, COMMAND_TEXT, EXPLANATION, SORT_ORDER)
  VALUES ('CMD_SNAP_RESTORE', 'SNAPSHOTS', 'Golden Snapshot Taastamine', './scripts/snapshots/restore-golden-snapshots.sh', 'Taastab andmebaasi kuldse hetktõmmise seisundisse ~15 sekundiga', 80);

MERGE INTO DEVHUB.DEVHUB_COMMANDS t USING (SELECT 'CMD_CI_TEST' AS id FROM dual) s ON (t.COMMAND_ID = s.id)
WHEN MATCHED THEN UPDATE SET
  t.CATEGORY = 'TOOLING', t.TITLE_KEY = 'Lokaalne CI/CD automaattest', t.COMMAND_TEXT = './scripts/test-local-ci.sh',
  t.EXPLANATION = 'Simuleerib CI toru: valideerib APEXlang ja Liquibase migratsioonid', t.SORT_ORDER = 90
WHEN NOT MATCHED THEN INSERT
  (COMMAND_ID, CATEGORY, TITLE_KEY, COMMAND_TEXT, EXPLANATION, SORT_ORDER)
  VALUES ('CMD_CI_TEST', 'TOOLING', 'Lokaalne CI/CD automaattest', './scripts/test-local-ci.sh', 'Simuleerib CI toru: valideerib APEXlang ja Liquibase migratsioonid', 90);

COMMIT;
PROMPT >>> ✅ DEVHUB seemneandmed edukalt sünkroniseeritud!
