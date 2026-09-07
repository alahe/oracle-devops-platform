# Jira Story: FIN-001 — Multi-Host Inventory & Environment Profile Engine

| Field | Value |
|:---|:---|
| **Story ID** | FIN-001 |
| **Epic** | Multi-Host Enterprise Infrastructure & Foundation |
| **Component** | CLI / Automation Engine / Remote Orchestrator |
| **Priority** | High |
| **Estimation** | **5 Story Points** |
| **Target Environments** | DEV, TEST, PROD |
| **Dependencies** | None |

---

## 1. User Story
**As a** Financial Enterprise DevOps Engineer / System Administrator,  
**I want to** define multi-host environment inventory profiles (`dev.env`, `test.env`, `prod.env`) containing dedicated host addresses and SSH settings for all 4 architectural tiers,  
**So that** deployment orchestration scripts (`scripts/deploy-remote.sh`) can autonomously target and provision distributed servers across different lifecycles without manual reconfiguration.

---

## 2. Business Value & Financial Compliance
- **Compliance (DORA Article 9 & PCI-DSS 2.2):** Guarantees strictly isolated configuration baselines across DEV, TEST, and PROD. Prevents cross-environment pollution and human error during remote deployment.
- **Auditability:** Every target host, IP, bastion gateway, and port is codified and version-controlled in Git, fulfilling enterprise change management requirements.

---

## 3. Technical Scope & Architecture

### Files Created / Modified:
1. `config/environments/dev.env`: Inventory defining DEV hosts (Server 1..4).
2. `config/environments/test.env`: Inventory defining TEST hosts (Server 1..4).
3. `config/environments/prod.env`: Inventory defining PROD Active (DC1) and Standby (DC2) hosts.
4. `scripts/deploy-remote.sh`: Enhanced to accept `--env-file <path>` and execute targeted multi-node deployment.
5. `scripts/internal/resolve-topology.sh`: Expanded to resolve remote multi-host port mappings and hostnames dynamically.

### Example Environment Profile Structure (`config/environments/dev.env`):
```ini
# Oracle DevOps Platform - Multi-Host Inventory (DEV)
ENVIRONMENT_NAME=DEV
BASTION_HOST=bastion.dev.bank
SSH_USER=opc
SSH_KEY_PATH=~/.ssh/id_ed25519

# Tier 1: ORDS + APEX App Server (Host 1)
ORDS_HOST=ords-dev.corp.bank
ORDS_PORT=8448

# Tier 2: Analytics Publisher Server (Host 2)
PUBLISHER_HOST=publisher-dev.corp.bank
PUBLISHER_PORT=9502

# Tier 3: PROXY DB Server (Host 3)
PROXY_DB_HOST=proxy-db-dev.corp.bank
PROXY_DB_PORT=1533
PROXY_DB_SERVICE=FREEPDB1

# Tier 4: Publisher DB Server (Host 4)
PUBLISHER_DB_HOST=publisher-db-dev.corp.bank
PUBLISHER_DB_PORT=1532
PUBLISHER_DB_SERVICE=FREEPDB1

# External: Existing Core Business DB
BIZ_DB_HOST=bizdb-dev.corp.bank
BIZ_DB_PORT=1521
BIZ_DB_SERVICE=BIZDEV.CORP.BANK
```

---

## 4. Definition of Done (DoD)
- [ ] Environment inventory files created for `dev.env`, `test.env`, and `prod.env` in `config/environments/`.
- [ ] `scripts/deploy-remote.sh --env-file <file> --dry-run` successfully parses all host definitions, prints a structured connectivity matrix, and exits with code 0.
- [ ] SSH connectivity check function verifies key-based authentication against all 4 remote tiers.
- [ ] No plaintext passwords or credentials exist in inventory files; all auth uses SSH public keys.
- [ ] Benchmarks and timing persisted into `metrics/setup_benchmarks.json` (Rule 1).

---

## 5. Acceptance Criteria & Verification
```bash
# Verify parsing of DEV inventory in dry-run mode:
./scripts/deploy-remote.sh --env-file config/environments/dev.env --dry-run

# Expected Output:
# ✅ [INVENTORY] Loaded configuration for DEV environment.
# 📍 Tier 1 (ORDS):        ords-dev.corp.bank:8448
# 📍 Tier 2 (Publisher):   publisher-dev.corp.bank:9502
# 📍 Tier 3 (Proxy DB):    proxy-db-dev.corp.bank:1533
# 📍 Tier 4 (Publisher DB):publisher-db-dev.corp.bank:1532
```
