# Rahoitusalan hajautetun arkkitehtuurin backlog (Jira eepokset & tarinat)

[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

Tämä backlog määrittää transformaation tiekartan, tekniset toimitukset ja Jira-käyttäjätarinat **Oracle DevOps & APEX -alustan** käyttöönotolle hajautetuissa Linux-ympäristöissä (**DEV, TEST, PROD**) varustettuna **Active/Standby -korkealla käytettävyydellä** ja integraatiolla yrityksen ydinliiketoimintatietokantaan.

---

## 📊 Backlogin Johdon Matriisi

- **Käyttäjätarinoita yhteensä:** 11 käyttäjätarinaa
- **Kokonaisarvio:** **62 Story Pointia (SP)**
- **Arkkitehtuurispesifikaatio:** [`docs/enterprise-distributed-architecture.md`](../enterprise-distributed-architecture.md)

| Story ID | Otsikko & Toimitus | Kerros / Komponentti | Arvio | Prioriteetti | Kohdeympäristö | Tila |
|:---|:---|:---|:---:|:---:|:---:|:---:|
| **[FIN-001](FIN-001-multi-host-inventory-and-profile-engine.md)** | Usean Palvelimen Inventaario- & Ympäristöprofiilimoottori | Infra / DevOps | **5 SP** | Korkea | DEV, TEST, PROD | Valmis |
| **[FIN-002](FIN-002-proxy-db-remote-container-deployment.md)** | Erillinen PROXY DB -etäkontti & APEX-moottori | DB-kerros (Host 3) | **5 SP** | Estävä | DEV, TEST, PROD | Valmis |
| **[FIN-003](FIN-003-publisher-db-remote-container-deployment.md)** | Erillinen Publisher DB -etäkontti & RCU-skeemat | DB-kerros (Host 4) | **5 SP** | Korkea | DEV, TEST, PROD | Valmis |
| **[FIN-004](FIN-004-standalone-ords-apex-server-deployment.md)** | Erillinen ORDS + APEX -sovelluspalvelimen käyttöönotto | Sovelluskerros (Host 1) | **8 SP** | Estävä | DEV, TEST, PROD | Valmis |
| **[FIN-005](FIN-005-standalone-analytics-publisher-server-deployment.md)** | Erillinen Analytics Publisher -palvelimen käyttöönotto | Sovelluskerros (Host 2) | **8 SP** | Korkea | DEV, TEST, PROD | Valmis |
| **[FIN-006](FIN-006-ords-multi-pool-business-db-wiring.md)** | ORDS-monipoolikonfiguraatio ydinliiketoimintatietokannalle | Integraatio | **5 SP** | Korkea | DEV, TEST, PROD | Valmis |
| **[FIN-007](FIN-007-publisher-jdbc-business-db-connection.md)** | Analytics Publisher JDBC -yhteys liiketoimintatietokantaan | Integraatio | **3 SP** | Keskitaso | DEV, TEST, PROD | Valmis |
| **[FIN-008](FIN-008-prod-active-standby-sync-and-failover.md)** | PROD Active/Standby Golden Snapshot -synkronointi & vikasietoisuus | DR / Käytettävyys | **8 SP** | Kriittinen | PROD (DC1/DC2) | Valmis |
| **[FIN-009](FIN-009-zero-trust-wallet-and-tls-distribution.md)** | Zero-Trust SEPS Wallet & TLS -jakeluautomaatio | Tietoturva / SecOps | **5 SP** | Korkea | DEV, TEST, PROD | Valmis |
| **[FIN-010](FIN-010-dev-test-prod-ci-cd-promotion-pipeline.md)** | Ympäristöjen välinen CI/CD-edistämisputki | CI/CD | **5 SP** | Keskitaso | Kaikki ympäristöt | Valmis |
| **[FIN-011](FIN-011-e2e-health-check-and-disaster-recovery-testing.md)** | E2E-integraatio-, terveys- ja vikasietotestaus | QA / Testaus | **5 SP** | Korkea | DEV, TEST, PROD | Valmis |
