[ 🇬🇧 English ](../../README.md) | [ 🇪🇪 Eesti ](../et/README.md) | [ 🇫🇮 Suomi ](../fi/README.md) | [ 🇸🇪 Svenska ](README.md) | [ 🇱🇻 Latviešu ](../lv/README.md) | [ 🇱🇹 Lietuvių ](../lt/README.md)

# Oracle DevOps Plattform (Svensk Guide)

> **Produktionsklar, licensavgiftsfri (0 €) och 100% lösenordsfri (SEPS Wallet) utvecklings- och DevOps-plattform för Oracle 23ai, APEX 26, Forms 14c, Publisher och Web IDE.**

---

## 🎯 Varför gör vi detta och vilka är fördelarna?

1. 💰 **Massiva Kostnadsbesparingar (0 € licensavgift):** Vi drar nytta av Oracle Database Free 23ai (JSON-Relational Duality, Kafka, APEX 26.1) och sparar enterprise-licenskostnader.
2. 🔒 **100% Lösenordsfri och Läcksäker (SEPS Wallet):** Oracle Wallet (SEPS) och Podman Secrets förhindrar lösenordsläckor i loggar och skript.
3. ⚡ **Startklar på Sekunder (Förbyggda Avbilder & Ögonblicksbilder):** Tack vare förbyggda containrar startar hela enterprise-miljön på **1–2 minuter istället för 15 minuter**.

---

## 📦 Arkitektoniska Modeller (Decade Matrix)

| Serie | Stacknamn | Containrar | Huvudfunktioner | Specifik Guide |
| :---: | :--- | :--- | :--- | :--- |
| **1–9** | **Core DB & APEX** | `db-alise`, `db-proxy`, `app-ords` | Oracle 23ai Free DB, APEX 26.1 Builder, multi-pool ORDS, REST Enabled SQL | 🗄️ **[config/blueprints/README.md](../../config/blueprints/README.md)** |
| **10–19** | **Analytics Publisher** | `db-publisher`, `app-publisher`, `app-ords` | Pixel Perfect PDF/Excel rapporter, WebLogic BI domän, RCU metadata | 📑 **[docs/publisher-setup.md](../publisher-setup.md)** |
| **20–29** | **Oracle Forms 14c** | `db-forms`, `app-forms`, `app-ords` | Forms Services 14.1.2 (`/forms/frmservlet`), testformulär (`test.fmx`), APEX migrering | 📐 **[docs/forms-setup.md](../forms-setup.md)** |
| **30–39** | **Web IDE & CI/CD** | `web-ide-dev`, `db-alise`, `app-ords` | Webbläsarbaserad VS Code (Port 8090), Oracle SQL Dev, Antigravity AI | 💻 **[docs/web-ide-artifactory.md](../web-ide-artifactory.md)** |
| **40–49** | **Ultimate Enterprise** | Alla containrar | Forms 14c + Publisher + APEX 26.1 + ORDS + Web IDE | 🌟 **[config/blueprints/README.md](../../config/blueprints/README.md)** |

---

## 🚀 Snabbstart (Quickstart CLI)

```bash
# 1. Starta önskad blueprint (t.ex. BP 30: Dev Workstation + Web IDE):
./scripts/setup-all.sh -b 30 --lang sv

# 2. Hämta lösenord säkert från SEPS Wallet:
./scripts/get-password.sh DB_DEV
./scripts/get-password.sh DB_APEX_ADMIN

# 3. Kontrollera aktiva webbtjänsters URL:er:
./scripts/check-urls.sh --lang sv

# 4. Kör verifieringstest för flerspråkighet (Regel 9: EN, ET, FI, SV, LV, LT):
./tests/test-multilingual-support.sh

# 5. Rensa loggar och tillfälliga filer:
./scripts/clean-logs.sh -y

# 6. Återställ miljön till rent utgångsläge:
./scripts/reset-all.sh -y
```

---

## 📑 Användarguider

- 🚀 **[docs/sv/forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md):** **Oracle Forms $\rightarrow$ APEX Moderniserings- och Migreringsguide** — Affärsnytta, TCO-jämförelse, 5-stegs automatiserat arbetsflöde och [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/).
- 📐 **[docs/forms-setup.md](../../docs/forms-setup.md):** Oracle Forms 14c Guide.
- 📑 **[docs/publisher-setup.md](../../docs/publisher-setup.md):** Analytics Publisher Guide.
- 💻 **[docs/web-ide-artifactory.md](../../docs/web-ide-artifactory.md):** Web IDE Guide.
- 🌐 **[docs/dev-hub.html](../../docs/dev-hub.html):** **Developer & DevOps Command Center** (`http://localhost:8088/` och `http://localhost:6082/vnc.html`).
- 📊 **[config/blueprints/README.md](../../config/blueprints/README.md):** Blueprint-katalog.
- 📖 **[Oracle APEX 26.1 APEXlang Reference Manual](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/):** Officiell specifikation för deklarativ `.apx`-grammatik och kompilatorkommandon.
