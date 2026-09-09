# Finanšu uzņēmuma sadalītās arhitektūras backlog (Jira epics & lietotāju stāsti)

[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

Šis backlog definē transformācijas ceļvedi, tehniskos nodevumus un Jira lietotāju stāstus **Oracle DevOps & APEX platformas** ieviešanai sadalītās Linux vidēs (**DEV, TEST, PROD**) ar **Active/Standby Augstu Pieejamību** un integrāciju ar uzņēmuma pamatdarbības datubāzi.

---

## 📊 Backlog Vadības Matrica

- **Kopējais stāstu skaits:** 11 lietotāju stāsti
- **Kopējais novērtējums:** **62 Story Points (SP)**
- **Arhitektūras specifikācija:** [`docs/enterprise-distributed-architecture.md`](../enterprise-distributed-architecture.md)

| Story ID | Nosaukums un Nodevums | Slānis / Komponents | Novērtējums | Prioritāte | Mērķa vide | Statuss |
|:---|:---|:---|:---:|:---:|:---:|:---:|
| **[FIN-001](FIN-001-multi-host-inventory-and-profile-engine.md)** | Vairāku Resursdatoru Inventāra & Vides Profilu Dzinējs | Infra / DevOps | **5 SP** | Augsta | DEV, TEST, PROD | Gatavs |
| **[FIN-002](FIN-002-proxy-db-remote-container-deployment.md)** | Specializēts PROXY DB Attālinātais Konteiners & APEX Dzinējs | DB slānis (Host 3) | **5 SP** | Bloķējoša | DEV, TEST, PROD | Gatavs |
| **[FIN-003](FIN-003-publisher-db-remote-container-deployment.md)** | Specializēts Publisher DB Attālinātais Konteiners & RCU Shēmas | DB slānis (Host 4) | **5 SP** | Augsta | DEV, TEST, PROD | Gatavs |
| **[FIN-004](FIN-004-standalone-ords-apex-server-deployment.md)** | Savrups ORDS + APEX Lietojumprogrammu Servera Izvietojums | Lietotņu slānis (Host 1) | **8 SP** | Bloķējoša | DEV, TEST, PROD | Gatavs |
| **[FIN-005](FIN-005-standalone-analytics-publisher-server-deployment.md)** | Savrups Analytics Publisher Servera Izvietojums | Lietotņu slānis (Host 2) | **8 SP** | Augsta | DEV, TEST, PROD | Gatavs |
| **[FIN-006](FIN-006-ords-multi-pool-business-db-wiring.md)** | ORDS Vairāku Pūlu Konfigurācija Pamatdarbības DB | Integrācija | **5 SP** | Augsta | DEV, TEST, PROD | Gatavs |
| **[FIN-007](FIN-007-publisher-jdbc-business-db-connection.md)** | Analytics Publisher JDBC Savienojums ar Biznesa DB | Integrācija | **3 SP** | Vidēja | DEV, TEST, PROD | Gatavs |
| **[FIN-008](FIN-008-prod-active-standby-sync-and-failover.md)** | PROD Active/Standby Golden Snapshot Sinhronizācija & Pārslēgšana | DR / Pieejamība | **8 SP** | Kritiska | PROD (DC1/DC2) | Gatavs |
| **[FIN-009](FIN-009-zero-trust-wallet-and-tls-distribution.md)** | Zero-Trust SEPS Wallet & TLS Izplatīšanas Automatizācija | Drošība / SecOps | **5 SP** | Augsta | DEV, TEST, PROD | Gatavs |
| **[FIN-010](FIN-010-dev-test-prod-ci-cd-promotion-pipeline.md)** | Vairāku Vižu Paaugstināšanas CI/CD Konveijers | CI/CD | **5 SP** | Vidēja | Visas vides | Gatavs |
| **[FIN-011](FIN-011-e2e-health-check-and-disaster-recovery-testing.md)** | E2E Integrācijas, Veselības Pārbaudes & DR Testēšana | QA / Testēšana | **5 SP** | Augsta | DEV, TEST, PROD | Gatavs |
