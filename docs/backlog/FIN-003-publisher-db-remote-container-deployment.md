# Jira Story: FIN-003 — Dedicated Publisher DB Remote Container & RCU Schemas

| Field | Value |
|:---|:---|
| **Story ID** | FIN-003 |
| **Epic** | Database Tier Provisioning & RCU Metadata |
| **Component** | Oracle 23ai Free DB / WebLogic RCU / Podman |
| **Priority** | High |
| **Estimation** | **5 Story Points** |
| **Target Environments** | DEV, TEST, PROD |
| **Dependencies** | FIN-001 |

---

## 1. User Story
**As an** Enterprise Reporting Administrator & WebLogic Specialist,  
**I want to** deploy a dedicated Oracle 23ai Free DB container on a remote Linux server (Host 4) containing the WebLogic Repository Creation Utility (RCU) schemas (`DEV_MDS`, `DEV_WLS`, `DEV_BIPLATFORM`),  
**So that** Analytics Publisher has a dedicated, performant metadata catalog and scheduler database completely independent of the application and business databases.

---

## 2. Business Value & Financial Compliance
- **Fault Isolation:** Prevents heavy report generation metadata operations, report scheduling tables, and audit logs from consuming transaction log space in the application or core business databases.
- **Maintainability:** Allows independent patching, restart, and backup of the reporting metadata layer without taking down user-facing APEX applications.

---

## 3. Technical Scope & Architecture

### Files Created / Modified:
1. `config/profiles/databases/db-publisher-remote.yaml`: Standalone database YAML profile for Server 4.
2. `scripts/internal/init-publisher-rcu.sh`: Automated idempotent RCU schema initializer.
3. `scripts/deploy-remote.sh`: Adds support for `--tier publisher-db`.

### Dedicated YAML Profile (`config/profiles/databases/db-publisher-remote.yaml`):
```yaml
name: db-publisher-remote
description: "Dedicated Remote Publisher RCU DB Container"
db_name: FREE
pdb_name: FREEPDB1
port: 1532
memory_limit: 3500m
container_name: db-publisher
users:
  - username: DEV_MDS
    default_tablespace: USERS
    quota: unlimited
  - username: DEV_BIPLATFORM
    default_tablespace: USERS
    quota: unlimited
```

---

## 4. Definition of Done (DoD)
- [ ] Profile `config/profiles/databases/db-publisher-remote.yaml` validated.
- [ ] Container `db-publisher` deployed and running under Podman rootless on Server 4.
- [ ] RCU schemas (`DEV_MDS`, `DEV_WLS_RUNTIME`, `DEV_BIPLATFORM`, `DEV_STB`) successfully verified in `dba_users`.
- [ ] SEPS Wallet alias `DB_PUBLISHER_READER` generated for Analytics Publisher connection.
- [ ] Step execution duration recorded in `metrics/setup_benchmarks.json`.

---

## 5. Acceptance Criteria & Verification
```bash
# Provision remote Publisher RCU DB:
./scripts/deploy-remote.sh --env-file config/environments/dev.env --tier publisher-db

# Validate RCU schema status:
./scripts/sqlcl.sh /@DB_PUBLISHER_READER -e "SELECT username, account_status FROM dba_users WHERE username LIKE 'DEV_%';"

# Expected Output:
# DEV_MDS          OPEN
# DEV_BIPLATFORM   OPEN
```
