# Jira Story: FIN-005 — Standalone Analytics Publisher Server Deployment

| Field | Value |
|:---|:---|
| **Story ID** | FIN-005 |
| **Epic** | Reporting Tier Provisioning & Document Engine |
| **Component** | Oracle Analytics Publisher 12c/14c / WebLogic / Podman |
| **Priority** | High |
| **Estimation** | **8 Story Points** |
| **Target Environments** | DEV, TEST, PROD |
| **Dependencies** | FIN-001, FIN-003 |

---

## 1. User Story
**As a** Corporate Reporting Developer & Financial System Architect,  
**I want to** deploy a standalone Oracle Analytics Publisher container on a dedicated Linux server (Host 2) connected to its RCU repository on Host 4,  
**So that** high-volume financial report rendering (PDF account statements, invoices, Excel balances) runs on dedicated compute resources without degrading interactive APEX web performance.

---

## 2. Business Value & Financial Compliance
- **CPU & Memory Protection:** PDF rendering and complex XML transformation (XSL-FO) are compute- and memory-intensive operations. Isolating them on Server 2 prevents browser freeze and transaction throttling on the APEX and database tiers.
- **Reporting SLA:** Guarantees SLA compliance for batch reporting generation during month-end financial closing.

---

## 3. Technical Scope & Architecture

### Files Created / Modified:
1. `config/profiles/publisher/publisher-standalone-remote.yaml`: Standalone Publisher YAML profile.
2. `docker-compose.publisher-remote.yml`: Compose definition deploying only Publisher on Server 2.
3. `scripts/internal/install-publisher.sh`: Remote execution parameters for remote RCU DB wiring.
4. `scripts/publisher/status-publisher.sh`: Validates Publisher runtime health on Server 2.
5. `scripts/deploy-remote.sh`: Adds support for `--tier publisher`.

### Standalone Publisher Profile (`config/profiles/publisher/publisher-standalone-remote.yaml`):
```yaml
name: publisher-standalone-remote
description: "Standalone Analytics Publisher Server on Host 2"
container_name: app-publisher
https_port: 9502
http_port: 9500
memory_limit: 4096m
remote_rcu_db_tns: DB_PUBLISHER_REMOTE
admin_user: bipadmin
```

---

## 4. Definition of Done (DoD)
- [ ] Container `app-publisher` running under Podman on Server 2 with systemd persistence.
- [ ] WebLogic Managed Server `bi_server1` reaches `RUNNING` state.
- [ ] Web UI on port 9502 accessible over TLS (`/xmlpserver`).
- [ ] Publisher successfully connects to Host 4 (`DB_PUBLISHER_REMOTE`) for RCU metadata loading.
- [ ] Execution benchmarks recorded in `metrics/setup_benchmarks.json` (Rule 1).

---

## 5. Acceptance Criteria & Verification
```bash
# Provision standalone remote Publisher server:
./scripts/deploy-remote.sh --env-file config/environments/dev.env --tier publisher

# Check publisher health status:
./scripts/publisher/status-publisher.sh --host publisher-dev.corp.bank

# Expected Output:
# ✅ Oracle Analytics Publisher 12c/14c: HEALTHY (HTTP 200 on /xmlpserver)
# 📊 Managed Server: bi_server1 [RUNNING]
```
