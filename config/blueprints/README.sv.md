[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏗️ Arkitektur Blueprints (15 Kuraterade Modeller)

Denna katalog fungerar som den **centrala och kanoniska källan för de 15 kuraterade arkitektur-blueprintsen** indelade i **4 logiska grupper**.

Varje blueprint (`.env.<N>-*`) definierar en komplett infrastrukturmodell från en fristående databas eller gateway till en komplett företagsinriktad hybridstack med Web IDE.

---

## 🚀 Kommandon för Hantering & Driftsättning

Använd det dedikerade styrskriptet **`./scripts/deploy-blueprint.sh`** (eller `./scripts/setup-all.sh -b <N>`):

```bash
# 1. Kontrollera aktiv blueprint och containerstatus:
./scripts/deploy-blueprint.sh --status --lang sv

# 2. Driftsätt eller byt till Blueprint 21 (STANDARD 2-lagers produktionsstack med Web IDE):
./scripts/deploy-blueprint.sh -b 21 --lang sv

# 3. Driftsätt Blueprint 31 (Ultimate Enterprise Hybridstack: Forms + Publisher + APEX + Web IDE):
./scripts/deploy-blueprint.sh -b 31 --lang sv

# 4. Dry-run simulering (förhandsgranska utan containerändringar):
./scripts/deploy-blueprint.sh -b 21 --dry-run

# 5. Visa tabell med alla 15 blueprints:
./scripts/setup-all.sh -lb --lang sv

# 6. Kör automatiserat rent test:
./scripts/setup-all.sh -tb 21
```

---

## 📊 Kanonisk 15-Blueprint Arkitekturmatris

```mermaid
graph TD
  subgraph Grupp 1: Fristående Produkter (1–9)
    BP1["BP 1: Fristående ALISE DB<br/>db-alise + app-ords (Port 1533)"]
    BP2["BP 2: Fristående ORDS & Dev Hub<br/>app-ords (Portar 8088/8448)"]
    BP3["BP 3: Fristående Proxy DB & APEX SSO<br/>db-proxy + app-ords (Port 1532)"]
    BP4["BP 4: Fristående Web-IDE Arbetsstation<br/>web-ide-dev (Port 8090)"]
    BP5["BP 5: Fristående Analytics Publisher<br/>db-publisher + app-publisher (Portar 1531, 9502)"]
    BP6["BP 6: Fristående Oracle Forms 14c<br/>db-forms + app-forms (Portar 1534, 9001, 6082)"]
  end

  subgraph Grupp 2: Konsoliderade Tjänster (10–19)
    BP10["BP 10: Forms + Publisher Gemensam DB<br/>db-publisher + app-forms + app-publisher"]
    BP11["BP 11: Konsoliderad ORDS & Web-IDE<br/>app-ords + web-ide-dev"]
  end

  subgraph Grupp 3: Skiktad Enterprise-Stack (20–29)
    BP20["BP 20: 1-DB Kärnapplikationsstack<br/>db-alise + app-ords + web-ide-dev"]
    BP21["🌟 BP 21 (STANDARD): Kanonisk 2-Lagers Stack<br/>db-proxy + db-alise + app-ords + web-ide-dev"]
    BP22["BP 22: 1-DB Kompakt Rapporteringsstack<br/>db-alise + app-publisher + app-ords + web-ide-dev"]
    BP23["BP 23: Fullständigt Isolerad Rapporteringsstack (3 DBs)<br/>db-publisher + db-proxy + db-alise + Publisher + ORDS + Web-IDE"]
    BP24["BP 24: Fullständigt Isolerad Forms-Stack (3 DBs)<br/>db-forms + db-proxy + db-alise + Forms + ORDS + Web-IDE"]
  end

  subgraph Grupp 4: Hybrida Stackar (30–39)
    BP30["BP 30: Kompakt Enterprise Hybridstack<br/>db-publisher + db-alise + Forms + Pub + ORDS + Web-IDE"]
    BP31["🌟 BP 31: Ultimate Enterprise Hybridstack<br/>db-publisher + db-proxy + db-alise + Forms + Pub + ORDS + Web-IDE"]
  end
```

---

### 🔹 Grupp 1: Fristående Produkter (1–9)
| Nr | Filnamn | Aktiva Containers | Värdportar | Syfte och Beskrivning |
| :--- | :--- | :--- | :--- | :--- |
| **1** | `.env.1-standalone-alise-db` | `db-alise`, `app-ords` | `1533`, `8088`, `8448` | **Fristående ALISE Affärsdatabas:** Dedikerad applikationsdatabas för affärsscheman, PL/SQL-kod och intern APEX/ORDS. |
| **2** | `.env.2-standalone-ords-devhub` | `app-ords` | `8088`, `8448` | **Fristående ORDS & Dev Hub:** HTTP/HTTPS-gateway och Developer Hub för fjärr- och molndatabaser. |
| **3** | `.env.3-standalone-proxy-db` | `db-proxy`, `app-ords` | `1532`, `8088`, `8448` | **Fristående Proxy DB & APEX SSO:** Säkerhetsgateway och extern anslutningsaktör (REST API, Azure Entra ID, Kafka). |
| **4** | `.env.4-standalone-web-ide` | `web-ide-dev` | `8090` | **Fristående Web-IDE Arbetsstation:** Webbaserad VS Code Web IDE med Oracle SQL Developer och CI-testning (`act`). |
| **5** | `.env.5-standalone-analytics-publisher` | `db-publisher`, `app-publisher` | `1531`, `9502` | **Fristående Analytics Publisher:** Pixel-Perfect företagsrapportering med dedikerad RCU-databas (`db-publisher`). |
| **6** | `.env.6-standalone-oracle-forms` | `db-forms`, `app-forms` | `1534`, `9001`, `7001`, `6082` | **Fristående Oracle Forms 14c:** Forms 14c Services och HTML5 noVNC Forms Builder GUI med Forms RCU-databas (`db-forms`). |

---

### 🔹 Grupp 2: Konsoliderade Tjänster (10–19)
| Nr | Filnamn | Aktiva Containers | Värdportar | Syfte och Beskrivning |
| :--- | :--- | :--- | :--- | :--- |
| **10** | `.env.10-consolidated-forms-publisher-unified-db` | `db-publisher`, `app-forms`, `app-publisher` | `1531`, `9502`, `9001`, `6082` | **Forms + Publisher Gemensam DB:** Forms 14c och Analytics Publisher på en gemensam 23ai DB (`db-publisher`) för båda RCU-scheman (~2.5 GB RAM-besparing). |
| **11** | `.env.11-consolidated-ords-web-ide` | `app-ords`, `web-ide-dev` | `8088`, `8448`, `8090` | **Konsoliderad ORDS Gateway & Web-IDE:** Integrerat webb- och utvecklarlager (ORDS gateway + code-server Web IDE) i ett enhetligt nätverk. |

---

### 🔹 Grupp 3: Skiktad Enterprise-Stack (20–29)
| Nr | Filnamn | Aktiva Containers | Värdportar | Syfte och Beskrivning |
| :--- | :--- | :--- | :--- | :--- |
| **20** | `.env.20-stack-alise-ords-webide` | `db-alise`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8448`, `8090` | **1-DB Kärnapplikationsstack:** En-databas APEX-kärnstack: ALISE affärsdatabas, ORDS-gateway och webbaserad Web IDE. |
| **21** | `.env.21-stack-alise-ords-proxy-webide` | `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev` | `1532`, `1533`, `8088`, `8448`, `8090` | **🌟 STANDARD:** Kanonisk 2-lagers säker nätverkstopologi (isolerad Proxy DB och ALISE DB) med APEX SSO, ORDS och Web IDE. |
| **22** | `.env.22-stack-alise-publisher-ords-webide` | `db-alise`, `app-publisher`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8448`, `9502`, `8090` | **1-DB Kompakt Rapporteringsstack:** Resurseffektiv rapporteringsstack där Analytics Publisher delar RCU-scheman i ALISE-databasen. |
| **23** | `.env.23-stack-alise-ords-proxy-webide-publisher` | `db-publisher`, `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev`, `app-publisher` | `1531-1533`, `8088`, `9502`, `8090` | **Fullständigt Isolerad 2-Lagers Rapporteringsstack:** 3 isolerade databaser (`db-publisher`, `db-proxy`, `db-alise`), WebLogic Publisher, ORDS och Web IDE *(kräver $\ge 12\text{ GB}$ RAM)*. |
| **24** | `.env.24-stack-alise-ords-proxy-webide-forms` | `db-forms`, `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev`, `app-forms` | `1532-1534`, `8088`, `9001`, `6082`, `8090` | **Fullständigt Isolerad 2-Lagers Forms-Stack:** 3 isolerade databaser (`db-forms`, `db-proxy`, `db-alise`), Forms 14c Services, noVNC, ORDS och Web IDE *(kräver $\ge 12\text{ GB}$ RAM)*. |

---

### 🔹 Grupp 4: Hybrida Stackar (30–39)
| Nr | Filnamn | Aktiva Containers | Värdportar | Syfte och Beskrivning |
| :--- | :--- | :--- | :--- | :--- |
| **30** | `.env.30-hybrid-alise-forms-pub-ords-webide` | `db-publisher`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531`, `1533`, `8088`, `9502`, `9001`, `6082`, `8090` | **Kompakt Enterprise Hybridstack:** Resurseffektiv hybridstack: ALISE DB, konsoliderad Forms & Publisher RCU DB (`db-publisher`) och integrerad ORDS & Web-IDE. |
| **31** | `.env.31-hybrid-alise-proxy-forms-pub-ords-webide` | `db-publisher`, `db-proxy`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531-1533`, `8088`, `9502`, `9001`, `6082`, `8090` | **🌟 ULTIMATE ENTERPRISE HYBRIDSTACK:** Komplett 2-lagers Proxy + ALISE-arkitektur med konsoliderad Forms & Publisher RCU-databas och integrerad ORDS & Web-IDE *(kräver $\ge 12\text{ GB}$ RAM)*. |
