# Įmonių klasės paskirstytos daugelio mazgų architektūros specifikacija

[ 🇬🇧 English ](../enterprise-distributed-architecture.md) | [ 🇪🇪 Eesti ](../et/enterprise-distributed-architecture.md) | [ 🇫🇮 Suomi ](../fi/enterprise-distributed-architecture.md) | [ 🇸🇪 Svenska ](../sv/enterprise-distributed-architecture.md) | [ 🇱🇻 Latviešu ](../lv/enterprise-distributed-architecture.md) | [ 🇱🇹 Lietuvių ](enterprise-distributed-architecture.md)

---

## 1. Santrauka ir finansų sektoriaus atitiktis

Šis dokumentas apibrėžia gamybinio lygio, aukšto pasiekiamumo paskirstytą architektūrą Oracle DevOps & APEX platformos diegimui finansų įstaigose ir reguliuojamose aplinkose trijuose etapuose: **DEV**, **TEST** ir **PROD**.

### Atitikties reikalavimai
- **DORA ir EBA Gairės:** Užtikrina veiklos tęstinumą per dviejų duomenų centrų **Active / Standby** modelį su **RTO < 60s** ir **RPO < 15m**.
- **PCI-DSS ir ISO/IEC 27001:** Jokių atviro teksto slaptažodžių diske, privalomas TLS 1.3 / mTLS šifravimas, AES-256 Oracle SEPS Auto-Login Wallet ir rootless Podman izoliacija.
- **4 Paskirstyti Sluoksniai:** Pašalina bendrą gedimo tašką (SPOF), paskirstant apkrovą į 4 dedikuotus serverius kiekvienoje aplinkoje.

---

## 2. Paskirstyta 4 sluoksnių architektūros topologija

Kiekviena aplinka (DEV, TEST, PROD) veikia 4 dedikuotuose Linux serveriuose:
- **1 Sluoksnis (1 Mazgas):** Atskiras **ORDS + APEX Images** (prievadai 8448/443) su kelių baseinų maršrutizavimu.
- **2 Sluoksnis (2 Mazgas):** Atskiras **Oracle Analytics Publisher** (prievadai 9502/443) ataskaitų generavimui.
- **3 Sluoksnis (3 Mazgas):** Dedikuota **PROXY DB** (Oracle 23ai Free DB konteineryje) su APEX varikliu ir DevHub.
- **4 Sluoksnis (4 Mazgas):** Dedikuota **Publisher DB** (Oracle 23ai Free DB konteineryje) WebLogic RCU metaduomenims.
- **Esama Verslo Duomenų Bazė:** Pasiekiama tiesiogiai per ORDS Multi-Pool ir Publisher JDBC.
