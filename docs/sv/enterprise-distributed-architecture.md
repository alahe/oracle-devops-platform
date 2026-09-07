# Företagsklassad distribuerad multi-host arkitektur

[ 🇬🇧 English ](../enterprise-distributed-architecture.md) | [ 🇪🇪 Eesti ](../et/enterprise-distributed-architecture.md) | [ 🇫🇮 Suomi ](../fi/enterprise-distributed-architecture.md) | [ 🇸🇪 Svenska ](enterprise-distributed-architecture.md) | [ 🇱🇻 Latviešu ](../lv/enterprise-distributed-architecture.md) | [ 🇱🇹 Lietuvių ](../lt/enterprise-distributed-architecture.md)

---

## 1. Sammanfattning och finansiell efterlevnad

Detta dokument definierar den produktionsklara, högspecialiserade distribuerade multi-host-arkitekturen för Oracle DevOps & APEX-plattformen inom finansinstitut och reglerade företagsmiljöer över tre livscykelstadier: **DEV**, **TEST** och **PROD**.

### Regulatoriska invarianter
- **DORA & EBA Riktlinjer:** Säkerställer affärskontinuitet via en **Active / Standby**-modell i två datacenter med **RTO < 60s** och **RPO < 15m**.
- **PCI-DSS & ISO/IEC 27001:** Inga lösenord i klartext, obligatorisk TLS 1.3 / mTLS-kryptering, AES-256 Oracle SEPS Auto-Login Wallet, rootless Podman-isolering och minsta behörighet för databasåtkomst.
- **4 Distribuerade Skikt:** Eliminerar SPOF och resurskonflikter genom att fördela arbetsbördan på 4 dedikerade servrar per miljö.

---

## 2. Distribuerad 4-skikts arkitekturtopologi

Varje miljö (DEV, TEST, PROD) körs på 4 dedikerade Linux-servrar:
- **Skikt 1 (Värd 1):** Fristående **ORDS + APEX Images** (portar 8448/443) med multi-pool-routning.
- **Skikt 2 (Värd 2):** Fristående **Oracle Analytics Publisher** (portar 9502/443) för pixel-perfect rapportering.
- **Skikt 3 (Värd 3):** Dedikerad **PROXY DB** (Oracle 23ai Free DB i container) med APEX-kärnan och DevHub.
- **Skikt 4 (Värd 4):** Dedikerad **Publisher DB** (Oracle 23ai Free DB i container) för WebLogic RCU.
- **Befintlig Verksamhetsdatabas:** Ansluts direkt via ORDS Multi-Pool och Publisher JDBC.
