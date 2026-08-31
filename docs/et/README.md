[ 🇬🇧 English ](../../README.md) | [ 🇪🇪 Eesti ](README.md) | [ 🇫🇮 Suomi ](../fi/README.md) | [ 🇸🇪 Svenska ](../sv/README.md) | [ 🇱🇻 Latviešu ](../lv/README.md) | [ 🇱🇹 Lietuvių ](../lt/README.md)

# Oracle DevOps Platvorm (Eesti Juhend)

> **Toodangukõlblik, litsentsitasudeta (0 €) ja 100% paroolivaba (SEPS Wallet) Oracle 23ai, APEX 26, Forms 14c, Publisher ja Web IDE arendus- ning DevOps platvorm.**

---

## 🎯 Miks me seda teeme ja millist kasu me saame?

1. 💰 **Massiivne Kulusääst (0 € litsentsitasu):** Kasutame ära tasuta Oracle Database Free 23ai tipptehnoloogiat (JSON-Relational Duality, Kafka, APEX 26.1), hoides kokku enterprise-litsentsidelt.
2. 🔒 **100% Paroolivaba ja Lekkevaba (SEPS Wallet):** Oracle Wallet (SEPS) ja Podman Secrets välistavad paroolide sattumise failidesse, logidesse või `ps aux` väljundisse. Arendaja logib sisse ühe klikiga.
3. ⚡ **Sekunditega Stardivalmis (Prebuilt Kujutised & Snapshots):** Tänu eelküpsetatud kujutistele käivituvad täielikud enterprise-stäkid **15 minuti asemel 1–2 minutiga**.

---

## 📦 Pakutavad Funktsionaalsused ja Konteinerstäkid (Decade Matrix)

Platvorm pakub **23 kanoonilist arhitektuurset kavandit (Environment Blueprints)**, mis on jaotatud 5 loogilisse seeriasse:

| Seeria | Stäki Nimi | Käivitatavad Konteinerid | Peamised Funktsionaalsused | Spetsiifiline Juhend |
| :---: | :--- | :--- | :--- | :--- |
| **1–9** | **Core DB & APEX** | `db-alise`, `db-proxy`, `app-ords` | Oracle 23ai Free DB, APEX 26.1 Builder, multi-pool ORDS, REST Enabled SQL | 🗄️ **[config/blueprints/README.et.md](../../config/blueprints/README.et.md)** |
| **10–19** | **Analytics Publisher** | `db-publisher`, `app-publisher`, `app-ords` | Pixel Perfect PDF/Excel aruanded, WebLogic BI domain, RCU metaandmed, `PUBLISHER_READER` wallet | 📑 **[docs/et/publisher-setup.md](publisher-setup.md)** |
| **20–29** | **Oracle Forms 14c** | `db-forms`, `app-forms`, `app-ords` | Forms Services 14.1.2 (`/forms/frmservlet`), testvorm (`test.fmx`), CLI partii-kompileerimine, APEX migratsioon | 📐 **[docs/et/forms-setup.md](forms-setup.md)** |
| **30–39** | **Web IDE & CI/CD** | `web-ide-dev`, `db-alise`, `app-ords` | Brauseripõhine VS Code (Port 8090), Oracle SQL Dev, Antigravity AI, offline GitHub Actions (`act`) | 💻 **[docs/et/web-ide-artifactory.md](web-ide-artifactory.md)** |
| **40–49** | **Ultimate Enterprise** | Kõik teenused koos | Forms 14c + Publisher + APEX 26.1 + ORDS + Web IDE (kõik-ühes ja isoleeritud mudelid) | 🌟 **[config/blueprints/README.et.md](../../config/blueprints/README.et.md)** |

---

## 🚀 Kiirkäivituse Spikker (Quickstart CLI)

```bash
# 1. Käivita soovitud blueprint (nt BP 41: All-in-One Enterprise või BP 43: Hübriid 2-DB):
./scripts/setup-all.sh -b 41 --lang et

# 2. Vaata paroolide ja teenuste koondtabelit (või kopeeri parool lõikelauale -c abil):
./scripts/get-password.sh
./scripts/get-password.sh DB_PROXY_DEV -c
./scripts/get-password.sh DB_PROXY_APEX_ADMIN -c

# 3. Kiire ja Turvalise Sisselogimise Juhend:
# 👉 Vaata: docs/et/quick-login-guide.md

# 4. Roteeri paroole turvaliselt (uuendab andmebaasi, Podman Secretid ja SEPS Walleti):
./scripts/rotate-password.sh db-proxy dev
./scripts/rotate-password.sh all

# 5. Kontrolli aktiivsete veebiteenuste (14 otspunkti sh APEX, Forms, Publisher, Web IDE) URL-e:
./scripts/check-urls.sh --lang et

# 6. Kontrolli SEPS paroolivabu Oracle Wallet ühendusi:
./scripts/check-wallet.sh

# 7. Käivita mitmekeelsuse (i18n) testikomplekt (Reegel 9: EN, ET, FI, SV, LV, LT):
./tests/test-multilingual-support.sh

# 8. Loo või taasta Kuldseid Hetktõmmiseid (kiire ~15s taastumine):
./scripts/snapshots/create-golden-snapshots.sh
./scripts/snapshots/restore-golden-snapshots.sh

# 9. Puhasta logid, ajutised failid ja vanad hetktõmmised:
./scripts/clean-logs.sh -y
./scripts/snapshots/clean-golden-snapshots.sh -y

# 10. Lähtesta keskkond puhtale algseisule:
./scripts/reset-all.sh -y
```

---

## 📑 Spetsiifilised Juhendid Kasutajale

- 🚀 **[docs/et/forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md):** **Oracle Forms $\rightarrow$ APEX Migratsiooni- ja Moderniseerimisjuhend** — Äriline põhjendus, TCO kuluvõrdlus, 5-etapiline automaatne töövoog, PL/SQL äriloogika eraldamine ja [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/) Vibe-Coding.
- 📐 **[docs/et/forms-setup.md](forms-setup.md):** Oracle Forms 14c kasutusjuhend — portide kaart (9001/7001/6082), testvormi avamine (`frmservlet?form=test.fmx`), vormide lisamine kausta `forms_apps/`, kompileerimine ja APEX-isse migratsioon.
- 📑 **[docs/et/publisher-setup.md](publisher-setup.md):** Analytics Publisheri kasutusjuhend — port 9502 (`/xmlpserver`), RCU metaandmete baas, `PUBLISHER_READER` Wallet konto, JDBC andmeallikate sidumine ja aruannete tarne.
- 💻 **[docs/et/web-ide-artifactory.md](web-ide-artifactory.md):** Web IDE kasutusjuhend — VS Code laiendused (Oracle SQL Developer, Antigravity AI, GitHub Actions), host-ühenduste reaalajas sünkroonimine ja offline GitHub Actions testimine (`act`).
- 🌐 **[docs/dev-hub.html](../../docs/dev-hub.html):** **Arendaja ja DevOps Juhtimiskeskus (Command Center)** — Kättesaadav aadressil **`http://localhost:8088/`** ja **`https://localhost:8448/`** (ORDS) ning **`http://localhost:6082/vnc.html`** (Forms). Sisaldab reaalajas latentsuse mõõtmist, interaktiivseid Mermaid arhitektuurijooniseid, 23 Blueprinti kataloogi, brauserisisest Markdown dokumentatsiooni lugerit, peidetavat SEPS Wallet paroolide maatriksit ning DevOps kiirkäskude juhtpaneeli 6 keeles (🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT).
- 📊 **[config/blueprints/README.et.md](../../config/blueprints/README.et.md):** Kõigi 23 arhitektuurse kavandi detailne tehniline maatriks.
- 📖 **[Oracle APEX 26.1 APEXlang Reference Manual](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/):** Oracle'i ametlik spetsifikatsioon deklaratiivse `.apx` grammatika, translaatori AST sõlmede ja CLI käskude kohta.
