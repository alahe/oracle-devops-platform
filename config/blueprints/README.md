[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏗️ Architecture Blueprints (15 Curated Enterprise Models)

This directory serves as the **central and canonical single source of truth for the 15 curated architecture blueprints** organized into **4 decade-based logical groups**.

Each blueprint (`.env.<N>-*`) defines a complete infrastructure model ranging from a standalone isolate database or gateway to an ultimate enterprise hybrid stack with Web IDE.

---

## 🚀 Blueprint Management & Deployment CLI Commands

Use the dedicated orchestration script **`./scripts/deploy-blueprint.sh`** (or `./scripts/setup-all.sh -b <N>`):

```bash
# 1. Check current active blueprint and container health:
./scripts/deploy-blueprint.sh --status

# 2. Deploy or switch to Blueprint 21 (DEFAULT 2-layer production stack with Web IDE):
./scripts/deploy-blueprint.sh -b 21

# 3. Deploy Blueprint 31 (Ultimate Enterprise Hybrid Stack with Forms + Publisher + APEX + Web IDE):
./scripts/deploy-blueprint.sh -b 31

# 4. Dry-run simulation (preview actions without modifying containers):
./scripts/deploy-blueprint.sh -b 21 --dry-run

# 5. List all available curated blueprints in a formatted ASCII table:
./scripts/setup-all.sh -lb

# 6. Run automated clean test suite on a blueprint:
./scripts/setup-all.sh -tb 21
```

---

## 📊 Canonical 15-Blueprint Architecture Matrix

```mermaid
graph TD
  subgraph Group 1: Standalone Isolates (1–9)
    BP1["BP 1: Standalone ALISE DB<br/>db-alise + app-ords (Port 1533)"]
    BP2["BP 2: Standalone ORDS & Dev Hub<br/>app-ords (Ports 8088/8448)"]
    BP3["BP 3: Standalone Proxy DB & APEX SSO<br/>db-proxy + app-ords (Port 1532)"]
    BP4["BP 4: Standalone Web-IDE Workstation<br/>web-ide-dev (Port 8090)"]
    BP5["BP 5: Standalone Analytics Publisher<br/>db-publisher + app-publisher (Ports 1531, 9502)"]
    BP6["BP 6: Standalone Oracle Forms 14c<br/>db-forms + app-forms (Ports 1534, 9001, 6082)"]
  end

  subgraph Group 2: Combined Subsystems (10–19)
    BP10["BP 10: Forms + Publisher Unified DB<br/>db-publisher + app-forms + app-publisher"]
    BP11["BP 11: Consolidated ORDS & Web-IDE<br/>app-ords + web-ide-dev"]
  end

  subgraph Group 3: Layered Stacks (20–29)
    BP20["BP 20: 1-DB Core Application Stack<br/>db-alise + app-ords + web-ide-dev"]
    BP21["🌟 BP 21 (PLATFORM DEFAULT): Canonical 2-Layer Stack<br/>db-proxy + db-alise + app-ords + web-ide-dev"]
    BP22["BP 22: 1-DB Compact Reporting Stack<br/>db-alise + app-publisher + app-ords + web-ide-dev"]
    BP23["BP 23: Full Isolated Reporting Stack (3 DBs)<br/>db-publisher + db-proxy + db-alise + Publisher + ORDS + Web-IDE"]
    BP24["BP 24: Full Isolated Forms Stack (3 DBs)<br/>db-forms + db-proxy + db-alise + Forms + ORDS + Web-IDE"]
  end

  subgraph Group 4: Hybrid Stacks (30–39)
    BP30["BP 30: Compact Enterprise Hybrid Stack<br/>db-publisher + db-alise + Forms + Pub + ORDS + Web-IDE"]
    BP31["🌟 BP 31: Ultimate Enterprise Hybrid Stack<br/>db-publisher + db-proxy + db-alise + Forms + Pub + ORDS + Web-IDE"]
  end
```

---

### 🔹 Group 1: Standalone Isolates (1–9)
| No | File Name | Active Containers | Host Ports | Purpose & Description |
| :--- | :--- | :--- | :--- | :--- |
| **1** | `.env.1-standalone-alise-db` | `db-alise`, `app-ords` | `1533`, `8088`, `8448` | **Standalone ALISE Business DB:** Dedicated custom application database holding business schemas, PL/SQL code, DDL/DML, and internal APEX/ORDS. |
| **2** | `.env.2-standalone-ords-devhub` | `app-ords` | `8088`, `8448` | **Standalone ORDS & Dev Hub:** HTTP/HTTPS gateway and Developer Hub for Remote and Cloud Databases. |
| **3** | `.env.3-standalone-proxy-db` | `db-proxy`, `app-ords` | `1532`, `8088`, `8448` | **Standalone Proxy DB & APEX SSO:** Security gateway and external connection actor (REST API, Azure Entra ID, Kafka). |
| **4** | `.env.4-standalone-web-ide` | `web-ide-dev` | `8090` | **Standalone Web-IDE Workstation:** Browser-based VS Code Web IDE with Oracle SQL Developer extension and local CI testing (`act`). |
| **5** | `.env.5-standalone-analytics-publisher` | `db-publisher`, `app-publisher` | `1531`, `9502` | **Standalone Analytics Publisher:** Pixel-Perfect enterprise PDF/Excel reporting with dedicated RCU DB (`db-publisher`). |
| **6** | `.env.6-standalone-oracle-forms` | `db-forms`, `app-forms` | `1534`, `9001`, `7001`, `6082` | **Standalone Oracle Forms 14c:** Forms 14c Services & HTML5 noVNC Forms Builder GUI with dedicated Forms RCU DB (`db-forms`). |

---

### 🔹 Group 2: Combined Subsystems (10–19)
| No | File Name | Active Containers | Host Ports | Purpose & Description |
| :--- | :--- | :--- | :--- | :--- |
| **10** | `.env.10-consolidated-forms-publisher-unified-db` | `db-publisher`, `app-forms`, `app-publisher` | `1531`, `9502`, `9001`, `6082` | **Forms + Publisher Unified DB:** Forms 14c and Analytics Publisher sharing a single unified 23ai DB (`db-publisher`) for both RCU schemas, saving ~2.5 GB RAM. |
| **11** | `.env.11-consolidated-ords-web-ide` | `app-ords`, `web-ide-dev` | `8088`, `8448`, `8090` | **Consolidated ORDS Gateway & Web-IDE:** Integrated web and developer workstation layer (ORDS gateway + code-server Web IDE) in a unified network. |

---

### 🔹 Group 3: Layered Enterprise Stacks (20–29)
| No | File Name | Active Containers | Host Ports | Purpose & Description |
| :--- | :--- | :--- | :--- | :--- |
| **20** | `.env.20-stack-alise-ords-webide` | `db-alise`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8448`, `8090` | **1-DB Core Application Stack:** Single-database core APEX stack with dedicated ALISE business database, ORDS gateway, and browser Web IDE. |
| **21** | `.env.21-stack-alise-ords-proxy-webide` | `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev` | `1532`, `1533`, `8088`, `8448`, `8090` | **🌟 PLATFORM DEFAULT:** Canonical 2-layer secure network topology (isolated Proxy DB and ALISE DB) with APEX SSO Gateway, ORDS, and Web IDE. |
| **22** | `.env.22-stack-alise-publisher-ords-webide` | `db-alise`, `app-publisher`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8448`, `9502`, `8090` | **1-DB Compact Reporting Stack:** Resource-efficient reporting stack where Analytics Publisher shares RCU schemas inside the ALISE database. |
| **23** | `.env.23-stack-alise-ords-proxy-webide-publisher` | `db-publisher`, `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev`, `app-publisher` | `1531-1533`, `8088`, `9502`, `8090` | **Full Isolated 2-Layer Reporting Stack:** 3 isolated databases (`db-publisher`, `db-proxy`, `db-alise`), WebLogic Publisher, ORDS, and Web IDE *(requires $\ge 12\text{ GB}$ RAM)*. |
| **24** | `.env.24-stack-alise-ords-proxy-webide-forms` | `db-forms`, `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev`, `app-forms` | `1532-1534`, `8088`, `9001`, `6082`, `8090` | **Full Isolated 2-Layer Forms Stack:** 3 isolated databases (`db-forms`, `db-proxy`, `db-alise`), Forms 14c Services, noVNC, ORDS, and Web IDE *(requires $\ge 12\text{ GB}$ RAM)*. |

---

### 🔹 Group 4: Hybrid Stacks (30–39)
| No | File Name | Active Containers | Host Ports | Purpose & Description |
| :--- | :--- | :--- | :--- | :--- |
| **30** | `.env.30-hybrid-alise-forms-pub-ords-webide` | `db-publisher`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531`, `1533`, `8088`, `9502`, `9001`, `6082`, `8090` | **Compact Enterprise Hybrid Stack:** Resource-efficient hybrid stack with dedicated ALISE DB, consolidated Forms & Publisher RCU DB (`db-publisher`), and integrated ORDS & Web-IDE. |
| **31** | `.env.31-hybrid-alise-proxy-forms-pub-ords-webide` | `db-publisher`, `db-proxy`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531-1533`, `8088`, `9502`, `9001`, `6082`, `8090` | **🌟 ULTIMATE ENTERPRISE:** Complete 2-layer Proxy + ALISE architecture with consolidated Forms & Publisher RCU database and integrated ORDS & Web-IDE *(requires $\ge 12\text{ GB}$ RAM)*. |

