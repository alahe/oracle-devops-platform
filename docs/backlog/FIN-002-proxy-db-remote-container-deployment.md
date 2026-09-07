# Jira Story: FIN-002 — Dedicated PROXY DB Remote Container & APEX Engine

| Field | Value |
|:---|:---|
| **Story ID** | FIN-002 |
| **Epic** | Database Tier Provisioning & APEX Runtime |
| **Component** | Oracle 23ai Free DB / APEX 26.1 / Podman |
| **Priority** | Blocker |
| **Estimation** | **5 Story Points** |
| **Target Environments** | DEV, TEST, PROD |
| **Dependencies** | FIN-001 |

---

## 1. User Story
**As an** Enterprise Oracle DBA & APEX Developer,  
**I want to** provision a dedicated Oracle 23ai Free DB container on a remote Linux server (Host 3) with APEX 26.1 core runtime and the DevHub schema,  
**So that** the application and developer portal data is isolated from other services, running on a dedicated host without memory contention.

---

## 2. Business Value & Financial Compliance
- **Resource Guarantee:** Dedicated VM allocation ensures that database SGA/PGA memory limits (2GB RAM in Oracle Free DB) are not impacted by WebLogic or ORDS Java memory overhead.
- **Data Protection (GDPR / Banking Secrecy):** Isolates the APEX metadata and administrative control plane on a separate network segment from external traffic.

---

## 3. Technical Scope & Architecture

### Files Created / Modified:
1. `config/profiles/databases/db-proxy-remote.yaml`: Standalone database YAML profile for Server 3.
2. `scripts/internal/init-db-instance.sh`: Executes APEX 26.1 verification and runs `init-devhub-schema.sql` inside the remote container.
3. `scripts/deploy-remote.sh`: Adds support for targeting only the database tier: `--tier proxy-db`.

### Dedicated YAML Profile (`config/profiles/databases/db-proxy-remote.yaml`):
```yaml
name: db-proxy-remote
description: "Dedicated Remote PROXY DB Container for APEX & DevHub"
db_name: FREE
pdb_name: FREEPDB1
port: 1533
memory_limit: 3500m
container_name: db-proxy
users:
  - username: DEVHUB
    default_tablespace: USERS
    quota: unlimited
    wallet_alias: DB_PROXY_DEVHUB
```

---

## 4. Definition of Done (DoD)
- [ ] Profile `config/profiles/databases/db-proxy-remote.yaml` validated against schema.
- [ ] Container `db-proxy` running under Podman rootless on Server 3 with systemd unit enabled.
- [ ] Healthcheck status of `db-proxy` reaches `healthy` within 180 seconds.
- [ ] APEX core schemas (`APEX_240200` or `APEX_260100`) and `DEVHUB` schema are provisioned and valid (`dba_registry`).
- [ ] SEPS Auto-Login Wallet credentials generated for `DB_PROXY_DEVHUB` and `DB_PROXY_SYS` (Rule 5).

---

## 5. Acceptance Criteria & Verification
```bash
# Provision remote Proxy DB:
./scripts/deploy-remote.sh --env-file config/environments/dev.env --tier proxy-db

# Test database listener and SEPS wallet connectivity from Host 3:
./scripts/check-wallet.sh --alias DB_PROXY_DEVHUB

# Expected Output:
# ✅ SQLcl SEPS Wallet Connection: SUCCESS (User DEVHUB, PDB FREEPDB1)
```
