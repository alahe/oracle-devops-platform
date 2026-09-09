# Finansų įmonės paskirstytos architektūros backlog (Jira epikai & naudotojų istorijos)

[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

Šis backlog apibrėžia transformacijos gaires, techninius rezultatus ir Jira naudotojų istorijas **Oracle DevOps & APEX platformos** diegimui paskirstytose Linux aplinkose (**DEV, TEST, PROD**) su **Active/Standby Dideliu Pasiekiamumu** ir integracija su įmonės pagrindine verslo duomenų baze.

---

## 📊 Backlog Vadovybės Matrica

- **Iš viso istorijų:** 11 naudotojų istorijų
- **Bendras įvertinimas:** **62 Story Points (SP)**
- **Architektūros specifikacija:** [`docs/enterprise-distributed-architecture.md`](../enterprise-distributed-architecture.md)

| Story ID | Pavadinimas ir Rezultatas | Sluoksnis / Komponentas | Įvertinimas | Prioritetas | Tikslinė aplinka | Būsena |
|:---|:---|:---|:---:|:---:|:---:|:---:|
| **[FIN-001](FIN-001-multi-host-inventory-and-profile-engine.md)** | Kelių Mazgų Inventorizacijos & Aplinkos Profilių Variklis | Infra / DevOps | **5 SP** | Didelis | DEV, TEST, PROD | Paruošta |
| **[FIN-002](FIN-002-proxy-db-remote-container-deployment.md)** | Dedikuotas PROXY DB Nuotolinis Konteineris & APEX Variklis | DB sluoksnis (Host 3) | **5 SP** | Blokuojantis | DEV, TEST, PROD | Paruošta |
| **[FIN-003](FIN-003-publisher-db-remote-container-deployment.md)** | Dedikuotas Publisher DB Nuotolinis Konteineris & RCU Schemos | DB sluoksnis (Host 4) | **5 SP** | Didelis | DEV, TEST, PROD | Paruošta |
| **[FIN-004](FIN-004-standalone-ords-apex-server-deployment.md)** | Atskiras ORDS + APEX Taikomųjų Programų Serverio Diegimas | Taikomųjų programų sluoksnis (Host 1) | **8 SP** | Blokuojantis | DEV, TEST, PROD | Paruošta |
| **[FIN-005](FIN-005-standalone-analytics-publisher-server-deployment.md)** | Atskiras Analytics Publisher Serverio Diegimas | Taikomųjų programų sluoksnis (Host 2) | **8 SP** | Didelis | DEV, TEST, PROD | Paruošta |
| **[FIN-006](FIN-006-ords-multi-pool-business-db-wiring.md)** | ORDS Kelių Telkinių Konfigūracija Pagrindinei Verslo DB | Integracija | **5 SP** | Didelis | DEV, TEST, PROD | Paruošta |
| **[FIN-007](FIN-007-publisher-jdbc-business-db-connection.md)** | Analytics Publisher JDBC Ryšys su Verslo DB | Integracija | **3 SP** | Vidutinis | DEV, TEST, PROD | Paruošta |
| **[FIN-008](FIN-008-prod-active-standby-sync-and-failover.md)** | PROD Active/Standby Golden Snapshot Sinchronizavimas & Perjungimas | DR / Pasiekiamumas | **8 SP** | Kritinis | PROD (DC1/DC2) | Paruošta |
| **[FIN-009](FIN-009-zero-trust-wallet-and-tls-distribution.md)** | Zero-Trust SEPS Wallet & TLS Platinimo Automatizavimas | Sauga / SecOps | **5 SP** | Didelis | DEV, TEST, PROD | Paruošta |
| **[FIN-010](FIN-010-dev-test-prod-ci-cd-promotion-pipeline.md)** | Kelių Aplinkų Paaukštinimo CI/CD Konvejeris | CI/CD | **5 SP** | Vidutinis | Visos aplinkos | Paruošta |
| **[FIN-011](FIN-011-e2e-health-check-and-disaster-recovery-testing.md)** | E2E Automatinis Integravimas, Būklės Tikrinimas & DR Testai | QA / Testavimas | **5 SP** | Didelis | DEV, TEST, PROD | Paruošta |
