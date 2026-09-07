# Uzņēmuma Līmeņa Sadalītās Vairāku Resursdatoru Arhitektūras Specifikācija

[ 🇬🇧 English ](../enterprise-distributed-architecture.md) | [ 🇪🇪 Eesti ](../et/enterprise-distributed-architecture.md) | [ 🇫🇮 Suomi ](../fi/enterprise-distributed-architecture.md) | [ 🇸🇪 Svenska ](../sv/enterprise-distributed-architecture.md) | [ 🇱🇻 Latviešu ](enterprise-distributed-architecture.md) | [ 🇱🇹 Lietuvių ](../lt/enterprise-distributed-architecture.md)

---

## 1. Kopsavilkums un Finanšu Nozares Atbilstība

Šis dokuments definē ražošanas līmeņa, augstas pieejamības sadalīto vairāku resursdatoru arhitektūru Oracle DevOps & APEX platformas ieviešanai finanšu iestādēs un regulētās vidēs trīs dzīves cikla posmos: **DEV**, **TEST** un **PROD**.

### Atbilstības Pamatprincipi
- **DORA un EBA Vadlīnijas:** Nodrošina darbības nepārtrauktību ar divu datu centru **Active / Standby** modeli ar **RTO < 60s** un **RPO < 15m**.
- **PCI-DSS un ISO/IEC 27001:** Nav vienkārša teksta paroļu uz diska, obligāta TLS 1.3 / mTLS šifrēšana, AES-256 Oracle SEPS Auto-Login Wallet un rootless Podman izolācija.
- **4 Sadalīti Slāņi:** Novērš vienu kļūmes punktu (SPOF), sadalot darba slodzi pa 4 atsevišķiem serveriem katrā vidē.

---

## 2. Sadalītā 4 Slāņu Arhitektūra

Katra vide (DEV, TEST, PROD) darbojas uz 4 atsevišķiem Linux serveriem:
- **1. Slānis (1. Resursdators):** Savrups **ORDS + APEX Images** (porti 8448/443) ar multi-pool maršrutēšanu.
- **2. Slānis (2. Resursdators):** Savrups **Oracle Analytics Publisher** (porti 9502/443) pārskatu ģenerēšanai.
- **3. Slānis (3. Resursdators):** Dedicēta **PROXY DB** (Oracle 23ai Free DB konteinerā) ar APEX kodolu un DevHub.
- **4. Slānis (4. Resursdators):** Dedicēta **Publisher DB** (Oracle 23ai Free DB konteinerā) WebLogic RCU metadatiem.
- **Esošā Biznesa Datu Bāze:** Piekļūstama tieši caur ORDS Multi-Pool un Publisher JDBC.
