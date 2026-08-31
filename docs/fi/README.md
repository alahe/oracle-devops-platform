[ 🇬🇧 English ](../../README.md) | [ 🇪🇪 Eesti ](../et/README.md) | [ 🇫🇮 Suomi ](README.md) | [ 🇸🇪 Svenska ](../sv/README.md) | [ 🇱🇻 Latviešu ](../lv/README.md) | [ 🇱🇹 Lietuvių ](../lt/README.md)

# Oracle DevOps -Alusta (Suomenkielinen Käyttöopas)

> **Tuotantovalmis, lisenssimaksuton (0 €) ja 100% salasanaton (SEPS Wallet) kehitys- ja DevOps-alusta: Oracle 23ai, APEX 26, Forms 14c, Publisher ja Web IDE.**

---

## 🎯 Miksi teemme tämän ja mitä hyötyä saamme?

1. 💰 **Massiiviset Kustannussäästöt (0 € lisenssimaksuja):** Hyödynnämme ilmaisen Oracle Database Free 23ai:n huipputeknologiaa (JSON-Relational Duality, Kafka, APEX 26.1), säästäen yrityslisensseissä.
2. 🔒 **100% Salasanaton ja Vuotovapaa (SEPS Wallet):** Oracle Wallet (SEPS) ja Podman Secrets estävät salasanojen päätymisen tiedostoihin, lokeihin tai `ps aux` -tulosteisiin. Kehittäjä kirjautuu yhdellä klikkauksella.
3. ⚡ **Käynnistys Sekunneissa (Esiasennetut Kuvat & Snapshots):** Esikoottujen konttikuvien ansiosta täydelliset enterprise-pinot käynnistyvät **15 minuutin sijasta 1–2 minuutissa**.

---

## 📦 Toiminnallisuudet ja Konttipinot (Decade Matrix)

Alusta tarjoaa **23 kanonista arkkitehtuurisuunnitelmaa (Environment Blueprints)**, jotka on jaettu 5 loogiseen sarjaan:

| Sarja | Pinon Nimi | Suoritettavat Kontit | Tärkeimmät Toiminnallisuudet | Moduulin Opas |
| :---: | :--- | :--- | :--- | :--- |
| **1–9** | **Core DB & APEX** | `db-alise`, `db-proxy`, `app-ords` | Oracle 23ai Free DB, APEX 26.1 Builder, moniallas-ORDS, REST Enabled SQL | 🗄️ **[config/blueprints/README.fi.md](../../config/blueprints/README.fi.md)** |
| **10–19** | **Analytics Publisher** | `db-publisher`, `app-publisher`, `app-ords` | Pixel Perfect PDF/Excel -raportit, WebLogic BI -toimialue, RCU-metatiedot, `PUBLISHER_READER` wallet | 📑 **[docs/fi/publisher-setup.md](publisher-setup.md)** |
| **20–29** | **Oracle Forms 14c** | `db-forms`, `app-forms`, `app-ords` | Forms Services 14.1.2 (`/forms/frmservlet`), testilomake (`test.fmx`), CLI-eräkäännös, APEX-migraatio | 📐 **[docs/fi/forms-setup.md](forms-setup.md)** |
| **30–39** | **Web IDE & CI/CD** | `web-ide-dev`, `db-alise`, `app-ords` | Selainpohjainen VS Code (Portti 8090), Oracle SQL Dev, Antigravity AI, offline GitHub Actions (`act`) | 💻 **[docs/fi/web-ide-artifactory.md](web-ide-artifactory.md)** |
| **40–49** | **Ultimate Enterprise** | Kaikki palvelut yhdessä | Forms 14c + Publisher + APEX 26.1 + ORDS + Web IDE (kaikki-yhdessä ja eristetyt mallit) | 🌟 **[config/blueprints/README.fi.md](../../config/blueprints/README.fi.md)** |

---

## 🚀 Pikakäynnistyksen CLI-Komennot (Quickstart CLI)

```bash
# 1. Käynnistä haluttu blueprint (esim. BP 41: All-in-One Enterprise tai BP 43: Hybridi 2-DB):
./scripts/setup-all.sh -b 41 --lang fi

# 2. Tarkastele salasanojen ja palveluiden koontitaulukkoa (tai kopioi salasana leikepöydälle -c):
./scripts/get-password.sh
./scripts/get-password.sh DB_PROXY_DEV -c
./scripts/get-password.sh DB_PROXY_APEX_ADMIN -c

# 3. Nopea ja Turvallinen Kirjautumisopas:
# 👉 Katso: docs/fi/quick-login-guide.md

# 4. Kierrätä salasanat turvallisesti (päivittää tietokannan, Podman Secretit ja SEPS Walletin):
./scripts/rotate-password.sh db-proxy dev
./scripts/rotate-password.sh all

# 5. Tarkista aktiivisten verkkopalveluiden (APEX, Forms, Publisher, Web IDE) URL-osoitteet:
./scripts/check-urls.sh --lang fi

# 6. Tarkista SEPS salasanattomat Oracle Wallet -yhteydet:
./scripts/check-wallet.sh

# 7. Suorita monikielisyyden (i18n) testisarja (Sääntö 9: EN, ET, FI, SV, LV, LT):
./tests/test-multilingual-support.sh

# 8. Luo tai palauta Kultaisia Tilannevedoksia (~15s palautuminen):
./scripts/snapshots/create-golden-snapshots.sh
./scripts/snapshots/restore-golden-snapshots.sh

# 9. Puhdista lokit, väliaikaiset tiedostot ja vanhat tilannevedokset:
./scripts/clean-logs.sh -y
./scripts/snapshots/clean-golden-snapshots.sh -y

# 10. Nollaa ympäristö puhtaaseen alkutilaan:
./scripts/reset-all.sh -y
```

---

## 📑 Moduulikohtaiset Käyttöoppaat

- 🚀 **[docs/fi/forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md):** **Oracle Forms $\rightarrow$ APEX Modernisointi- ja Migraatio-opas** — Liiketoimintaperusteet, TCO-kustannusvertailu, 5-vaiheinen automaattinen työnkulku, PL/SQL-logiikan eristäminen ja [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/) Vibe-Coding.
- 📐 **[docs/fi/forms-setup.md](forms-setup.md):** Oracle Forms 14c käyttöohje — porttikartta (9001/7001/6082), testilomakkeen avaaminen (`frmservlet?form=test.fmx`), lomakkeiden lisääminen kansioon `forms_apps/`, kääntäminen ja APEX-migraatio.
- 📑 **[docs/fi/publisher-setup.md](publisher-setup.md):** Analytics Publisherin käyttöohje — portti 9502 (`/xmlpserver`), RCU-metatietokanta, `PUBLISHER_READER` Wallet -tili, JDBC-tietolähteiden liittäminen ja raporttien jakelu.
- 💻 **[docs/fi/web-ide-artifactory.md](web-ide-artifactory.md):** Web IDE -käyttöohje — VS Code -laajennukset (Oracle SQL Developer, Antigravity AI, GitHub Actions), isäntäyhteyksien reaaliaikainen synkronointi ja offline GitHub Actions -testaus (`act`).
- 🌐 **[docs/dev-hub.html](../../docs/dev-hub.html):** **Kehittäjän ja DevOpsin Komentokeskus (Developer Hub)** — Saatavilla osoitteissa **`http://localhost:8088/`** ja **`https://localhost:8448/`** (ORDS) sekä **`http://localhost:6082/vnc.html`** (Forms). Sisältää reaaliaikaisen latenssin seurannan, interaktiiviset Mermaid-arkkitehtuurikaaviot, 22+ Blueprintin luettelon, selaimensisäisen Markdown-lukijan ja DevOps-pikakomennot 6 kielellä (🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT).
- 📊 **[config/blueprints/README.fi.md](../../config/blueprints/README.fi.md):** Kaikkien 23 arkkitehtuurisuunnitelman tekninen matriisi.
- 📖 **[Oracle APEX 26.1 APEXlang Reference Manual](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/):** Oraclen virallinen spesifikaatio deklaratiivisesta `.apx`-kieliopista, kääntäjän AST-solmuista ja CLI-komennoista.
