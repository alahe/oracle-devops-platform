# Finansiell distribuerad arkitektur backlog (Jira epics & användarberättelser)

[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

Denna backlog definierar transformationsfärdplanen, tekniska leverabler och Jira-användarberättelser för distribution av **Oracle DevOps & APEX-plattformen** över distribuerade Linux-miljöer (**DEV, TEST, PROD**) med **Active/Standby Hög Tillgänglighet** och integration med företagets centrala affärsdatabas.

---

## 📊 Ledningsmatris för Backlog

- **Totalt antal berättelser:** 11 användarberättelser
- **Total uppskattning:** **62 Story Points (SP)**
- **Arkitekturspecifikation:** [`docs/enterprise-distributed-architecture.md`](../enterprise-distributed-architecture.md)

| Story ID | Titel & Leverabel | Skikt / Komponent | Uppskattning | Prioritet | Målmiljö | Status |
|:---|:---|:---|:---:|:---:|:---:|:---:|
| **[FIN-001](FIN-001-multi-host-inventory-and-profile-engine.md)** | Multi-Host Inventarie- & Miljöprofilsmotor | Infra / DevOps | **5 SP** | Hög | DEV, TEST, PROD | Klar |
| **[FIN-002](FIN-002-proxy-db-remote-container-deployment.md)** | Dedikerad PROXY DB Fjärrcontainer & APEX-motor | DB-skikt (Host 3) | **5 SP** | Blockerande | DEV, TEST, PROD | Klar |
| **[FIN-003](FIN-003-publisher-db-remote-container-deployment.md)** | Dedikerad Publisher DB Fjärrcontainer & RCU-scheman | DB-skikt (Host 4) | **5 SP** | Hög | DEV, TEST, PROD | Klar |
| **[FIN-004](FIN-004-standalone-ords-apex-server-deployment.md)** | Fristående ORDS + APEX Applikationsserverdistribution | App-skikt (Host 1) | **8 SP** | Blockerande | DEV, TEST, PROD | Klar |
| **[FIN-005](FIN-005-standalone-analytics-publisher-server-deployment.md)** | Fristående Analytics Publisher Serverdistribution | App-skikt (Host 2) | **8 SP** | Hög | DEV, TEST, PROD | Klar |
| **[FIN-006](FIN-006-ords-multi-pool-business-db-wiring.md)** | ORDS Multi-Pool Konfiguration för Central Affärsdatabas | Integration | **5 SP** | Hög | DEV, TEST, PROD | Klar |
| **[FIN-007](FIN-007-publisher-jdbc-business-db-connection.md)** | Analytics Publisher JDBC-anslutning till Affärsdatabas | Integration | **3 SP** | Medel | DEV, TEST, PROD | Klar |
| **[FIN-008](FIN-008-prod-active-standby-sync-and-failover.md)** | PROD Active/Standby Golden Snapshot Synk & Failover | DR / Tillgänglighet | **8 SP** | Kritisk | PROD (DC1/DC2) | Klar |
| **[FIN-009](FIN-009-zero-trust-wallet-and-tls-distribution.md)** | Zero-Trust SEPS Wallet & TLS Distributionsautomatisering | Säkerhet / SecOps | **5 SP** | Hög | DEV, TEST, PROD | Klar |
| **[FIN-010](FIN-010-dev-test-prod-ci-cd-promotion-pipeline.md)** | Kampanjpipeline över Miljöer för CI/CD | CI/CD | **5 SP** | Medel | Alla miljöer | Klar |
| **[FIN-011](FIN-011-e2e-health-check-and-disaster-recovery-testing.md)** | E2E Automatiserad Integration, Hälsa & Katastroftestning | QA / Testning | **5 SP** | Hög | DEV, TEST, PROD | Klar |
