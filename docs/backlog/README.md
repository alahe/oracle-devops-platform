# Financial Enterprise Distributed Backlog (Jira Epics & Stories)

[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

This backlog defines the transformation roadmap, technical deliverables, and Jira user stories for deploying the **Oracle DevOps & APEX Platform** across distributed remote Linux environments (**DEV, TEST, PROD**) with **Active/Standby High Availability** and integration with the enterprise core business database.

---

## 📊 Backlog Executive Matrix

- **Total Stories:** 11 User Stories
- **Total Estimation:** **62 Story Points (SP)**
- **Architecture Specification:** [`docs/enterprise-distributed-architecture.md`](../enterprise-distributed-architecture.md)

| Story ID | Title & Deliverable | Tier / Component | Estimation | Priority | Target Env | Status |
|:---|:---|:---|:---:|:---:|:---:|:---:|
| **[FIN-001](FIN-001-multi-host-inventory-and-profile-engine.md)** | Multi-Host Inventory & Environment Profile Engine | Infra / DevOps | **5 SP** | High | DEV, TEST, PROD | Ready |
| **[FIN-002](FIN-002-proxy-db-remote-container-deployment.md)** | Dedicated PROXY DB Remote Container & APEX Engine | DB Tier (Host 3) | **5 SP** | Blocker | DEV, TEST, PROD | Ready |
| **[FIN-003](FIN-003-publisher-db-remote-container-deployment.md)** | Dedicated Publisher DB Remote Container & RCU Schemas | DB Tier (Host 4) | **5 SP** | High | DEV, TEST, PROD | Ready |
| **[FIN-004](FIN-004-standalone-ords-apex-server-deployment.md)** | Standalone ORDS + APEX App Server Deployment | App Tier (Host 1) | **8 SP** | Blocker | DEV, TEST, PROD | Ready |
| **[FIN-005](FIN-005-standalone-analytics-publisher-server-deployment.md)** | Standalone Analytics Publisher Server Deployment | App Tier (Host 2) | **8 SP** | High | DEV, TEST, PROD | Ready |
| **[FIN-006](FIN-006-ords-multi-pool-business-db-wiring.md)** | ORDS Multi-Pool Configuration for Core Business DB | Integration | **5 SP** | High | DEV, TEST, PROD | Ready |
| **[FIN-007](FIN-007-publisher-jdbc-business-db-connection.md)** | Analytics Publisher JDBC Connection to Business DB | Integration | **3 SP** | Medium | DEV, TEST, PROD | Ready |
| **[FIN-008](FIN-008-prod-active-standby-sync-and-failover.md)** | PROD Active/Standby Golden Snapshot Sync & Failover | DR / Availability | **8 SP** | Critical | PROD (DC1/DC2) | Ready |
| **[FIN-009](FIN-009-zero-trust-wallet-and-tls-distribution.md)** | Zero-Trust SEPS Wallet & TLS Distribution Automation | Security / SecOps | **5 SP** | High | DEV, TEST, PROD | Ready |
| **[FIN-010](FIN-010-dev-test-prod-ci-cd-promotion-pipeline.md)** | Multi-Environment Promotion CI/CD Pipeline | CI/CD | **5 SP** | Medium | All Envs | Ready |
| **[FIN-011](FIN-011-e2e-health-check-and-disaster-recovery-testing.md)** | E2E Automated Integration, Health & Failover Verification | QA / Testing | **5 SP** | High | DEV, TEST, PROD | Ready |

---

## 🗺️ Delivery Roadmap & Sprint Plan

```mermaid
gantt
    title Financial Enterprise Rollout Roadmap (62 SP)
    dateFormat  YYYY-MM-DD
    section Sprint 1: Foundation (20 SP)
    FIN-001 Multi-Host Inventory & Profiles     :a1, 2026-09-08, 4d
    FIN-009 Zero-Trust SEPS Wallet & TLS        :a2, 2026-09-10, 4d
    FIN-002 PROXY DB Remote Deployment          :a3, 2026-09-12, 4d
    FIN-003 Publisher DB & RCU Deployment       :a4, 2026-09-14, 4d

    section Sprint 2: Application Tiers & Integration (24 SP)
    FIN-004 Standalone ORDS + APEX Server       :b1, 2026-09-18, 5d
    FIN-005 Standalone Analytics Publisher      :b2, 2026-09-20, 5d
    FIN-006 ORDS Multi-Pool Business DB Wiring  :b3, 2026-09-24, 4d
    FIN-007 Publisher JDBC Business DB Link     :b4, 2026-09-26, 3d

    section Sprint 3: High Availability & CI/CD (18 SP)
    FIN-008 PROD Active/Standby Sync & Failover :c1, 2026-09-29, 6d
    FIN-010 CI/CD Multi-Environment Promotion   :c2, 2026-10-02, 4d
    FIN-011 E2E Health Checks & DR Testing      :c3, 2026-10-05, 4d
```

---

## 📋 Definition of Done (Global Standard for All Stories)

For any story in this backlog to be marked as **DONE**:
1. **Code & Configuration:** All scripts, compose files, and YAML profiles are fully committed to Git and strictly follow Clean Blueprint (Rule 11) and Shell Portability (Rule 6).
2. **Zero-Trust Security:** No plaintext passwords or sensitive secrets reside on disk (`.env`, `.json`, logs); all credentials are authenticated via Oracle SEPS Wallet (`cwallet.sso`).
3. **Automated Verification:** Automated acceptance test script succeeds with exit code 0 and logs stored under `install_logs/`.
4. **Execution Timing & Benchmarks:** Execution duration is measured with second precision and recorded in `metrics/setup_benchmarks.json` (Rule 1).
5. **Documentation & i18n:** Architecture documentation, operational runbooks, and multi-language mirrors are updated in the same workflow cycle (Rule 2 & Rule 9).
