# Finantsettevõtte hajusarhitektuuri backlog (Jira eepikud & kasutajalood)

[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

See backlog määratleb transformatsiooni teekaardi, tehnilised tulemid ja Jira kasutajalood **Oracle DevOps & APEX Platvormi** juurutamiseks hajutatud Linuxi keskkondades (**DEV, TEST, PROD**) koos **Active/Standby Kõrge Saadavusega** ja integratsiooniga ettevõtte põhiäri andmebaasiga.

---

## 📊 Backlogi Juhtkonna Maatriks

- **Kasutajalugusid kokku:** 11 kasutajalugu
- **Kogumaht:** **62 Story Pointi (SP)**
- **Arhitektuuri spetsifikatsioon:** [`docs/enterprise-distributed-architecture.md`](../enterprise-distributed-architecture.md)

| Story ID | Pealkiri ja Tulem | Kiht / Komponent | Hinnang | Prioriteet | Sihtkeskkond | Staatus |
|:---|:---|:---|:---:|:---:|:---:|:---:|
| **[FIN-001](FIN-001-multi-host-inventory-and-profile-engine.md)** | Mitme Hostiga Inventuur & Keskkonnaprofiilide Mootor | Infra / DevOps | **5 SP** | Kõrge | DEV, TEST, PROD | Valmis |
| **[FIN-002](FIN-002-proxy-db-remote-container-deployment.md)** | Eraldi PROXY DB Kaugkonteiner & APEX Mootor | DB Kiht (Host 3) | **5 SP** | Blokeeriv | DEV, TEST, PROD | Valmis |
| **[FIN-003](FIN-003-publisher-db-remote-container-deployment.md)** | Eraldi Publisher DB Kaugkonteiner & RCU Skeemid | DB Kiht (Host 4) | **5 SP** | Kõrge | DEV, TEST, PROD | Valmis |
| **[FIN-004](FIN-004-standalone-ords-apex-server-deployment.md)** | Eraldiseisev ORDS + APEX Rakendusserveri Paigaldus | Rakenduste Kiht (Host 1) | **8 SP** | Blokeeriv | DEV, TEST, PROD | Valmis |
| **[FIN-005](FIN-005-standalone-analytics-publisher-server-deployment.md)** | Eraldiseisev Analytics Publisher Serveri Paigaldus | Rakenduste Kiht (Host 2) | **8 SP** | Kõrge | DEV, TEST, PROD | Valmis |
| **[FIN-006](FIN-006-ords-multi-pool-business-db-wiring.md)** | ORDS Mitme Pooli Seadistus Põhiäri Andmebaasile | Integratsioon | **5 SP** | Kõrge | DEV, TEST, PROD | Valmis |
| **[FIN-007](FIN-007-publisher-jdbc-business-db-connection.md)** | Analytics Publisher JDBC Ühendus Äriandmebaasile | Integratsioon | **3 SP** | Keskmine | DEV, TEST, PROD | Valmis |
| **[FIN-008](FIN-008-prod-active-standby-sync-and-failover.md)** | PROD Active/Standby Golden Snapshot Sünk ja Tõrkesiire | DR / Saadavus | **8 SP** | Kriitiline | PROD (DC1/DC2) | Valmis |
| **[FIN-009](FIN-009-zero-trust-wallet-and-tls-distribution.md)** | Zero-Trust SEPS Wallet & TLS Levitamise Automaatika | Turvalisus / SecOps | **5 SP** | Kõrge | DEV, TEST, PROD | Valmis |
| **[FIN-010](FIN-010-dev-test-prod-ci-cd-promotion-pipeline.md)** | Keskkondadeülese Edutamise CI/CD Konveier | CI/CD | **5 SP** | Keskmine | Kõik keskkonnad | Valmis |
| **[FIN-011](FIN-011-e2e-health-check-and-disaster-recovery-testing.md)** | E2E Automaattestid, Tervisekontroll & DR Tõrkesiire | QA / Testimine | **5 SP** | Kõrge | DEV, TEST, PROD | Valmis |
