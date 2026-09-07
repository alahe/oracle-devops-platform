[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📚 Dokumentaatiokeskus & sisällysluettelo

Tämä hakemisto sisältää Oracle DevOps -alustan tekniset määritykset, asennusoppaat ja arkkitehtuurikatsaukset.

---

## 🗺️ Aihepuu & pikalinkit

| Aihe | Dokumentti | Kuvaus |
| :--- | :--- | :--- |
| 💻 **Yrityksen Windows ja WSL2** | [windows-enterprise-setup-guide.md](windows-enterprise-setup-guide.md) | Zero-Admin WSL2 -asennus, 10-vaiheinen dry-run -diagnostiikka, Hyper-V -portit ja välityspalvelin. |
| 🏢 **Yrityksen onboarding ja peilit** | [enterprise-onboarding-guide.md](enterprise-onboarding-guide.md) | Artifactory-konttirekisteripeilien määritys, profiilien automaattinen päivitys ja palautus. |
| 🏛️ **Hajautettu 4-palvelimen arkkitehtuuri** | [enterprise-distributed-architecture.md](enterprise-distributed-architecture.md) | 4-palvelimen tuotantoarkkitehtuuri, active/standby -vikasietoisuus ja zero-trust -tietoturva. |
| 📋 **Yrityksen Jira backlog** | [backlog/README.md](backlog/README.md) | 11 käyttäjätarinaa, 62 tarinapistettä hajautetun käyttöönoton tiekartalla. |
| 🔄 **Tietokantakonttikuvien vaihto** | [database-image-switching-guide.md](database-image-switching-guide.md) | FastStart-pikakuvat, rekisteripeilit ja kontin sisäinen purkaminen. |
| 🔄 **3-tasoinen elinkaari ja tilannekuvat** | [devops-lifecycle-guide.md](devops-lifecycle-guide.md) | Kultaisten tilannekuvien nopea palautus (~15s), RMAN-varmuuskopiot ja toipumissuunnitelma. |
| 🧪 **Automaattitestaus ja Dev Hub** | [testing-framework-and-devhub.md](testing-framework-and-devhub.md) | Yli 160 automaattitestiä, reaaliaikainen arkkitehtuurin validointi ja Dev Hub. |
| 🚀 **Pikaopas kirjautumiseen** | [quick-login-guide.md](quick-login-guide.md) | 1-klikkauksen leikepöytätyökalut, SEPS Wallet -tunnistetietojen haku ja verkkolinkit. |
| 📋 **Arkkitehtuurin blueprint-matriisi** | [../config/blueprints/README.fi.md](../config/blueprints/README.fi.md) | 12 kanonisen mallin (0..11) vertailu ja resurssivaatimukset. |
| 🗄️ **Tietokantaprofiilit ja topologia** | [db-profiles-and-topology.md](db-profiles-and-topology.md) | YAML-profiilihierarkia (`config/profiles/databases/`), porttitopologia ja Sääntö 11. |
| 📑 **Analytics Publisher -asennus** | [publisher-setup.md](publisher-setup.md) | Publisher 2025 -asennus, verkkokäyttöliittymä (`/xmlpserver`), RCU-skeemat ja tietolähteet. |
| 📑 **Publisher REST API** | [publisher-guide.md](publisher-guide.md) | Pixel Perfect REST API -dokumenttien luonti ja automatisoitu jakelu. |
| 📑 **Publisher-mallien suunnittelu** | [publisher-template-builder-guide.md](publisher-template-builder-guide.md) | RTF- ja Excel-mallien suunnittelu Analytics Publisher -raporteille. |
| 📐 **Oracle Forms 14c -asennus** | [forms-setup.md](forms-setup.md) | Forms Services 14.1.2 -asennus, HTML5 noVNC Forms Builder GUI ja modernisointi APEXiin. |
| 🔄 **Forms -> APEX modernisointi** | [forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md) | Vaiheittainen tiekartta Forms/Reports-sovellusten viemiseksi moderniin APEXiin. |
| 💻 **Web IDE ja CI/CD** | [web-ide-artifactory.md](web-ide-artifactory.md) | VS Code Web IDE (`code-server`), esiasennetut laajennukset ja paikallinen CI (`act`). |
| 🛡️ **Tietoturva ja SSO** | [security.md](security.md) | Zero-Trust -salasanahallinta, Oracle SEPS Wallet ja Azure Entra-ID SSO. |
| 🔑 **Oracle Wallet -arkkitehtuuri** | [oracle-wallet-architecture-plan.md](oracle-wallet-architecture-plan.md) | SEPS Auto-Login Wallet, muistipohjainen salasanojen haku ja automaattinen kierto. |
| 🏢 **Artifactory-peilien asennus** | [artifactory-setup.md](artifactory-setup.md) | Yrityksen JFrog Artifactory -konttirekisterin ja repositorion konfigurointi. |
| 🌐 **ORDS-profiilit ja elinkaari** | [ords-profiles-lifecycle.md](ords-profiles-lifecycle.md) | Erilliset ja kontitetut ORDS-yhteysaltaat. |
| 📈 **Levytilan valvonta** | [oracle-free-db-monitoring.md](oracle-free-db-monitoring.md) | Oracle Free 12 GB -rajan seuranta ja automaattiset varoitukset. |
| 📉 **Lähtötilanteen mittarit** | [oracle-free-db-initial-state.md](oracle-free-db-initial-state.md) | Asennuksen jälkeinen levytilan ja taulutilojen käyttö. |
| 📦 **APEX-sovellusten jakelu** | [apex-apps-deployment.md](apex-apps-deployment.md) | APEX-sovellusten automaattinen tuonti hakemistosta `binaries/apex_apps/`. |
| 🌐 **Erillinen ORDS-palvelin** | [standalone-ords.md](standalone-ords.md) | Erillisen Oracle REST Data Services -palvelimen asennus Linux-koneeseen ilman Docker-konttia. |
| 🚀 **Asennustyönkulun arkkitehtuuri** | [setup-all-workflow.md](setup-all-workflow.md) | Täydellinen vuokaavio, idempotenssi ja Defender-optimoinnit. |
