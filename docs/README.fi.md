[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📚 Dokumentaatiokeskus & Sivukartta (Sitemap)

Tämä hakemisto sisältää Oracle DevOps Platforrmin tekniset arkkitehtuurispesifikaatiot, asennusoppaat ja toiminnalliset käsikirjat.

---

## 🗺️ Aihehakemisto & Pikalinkit

| Aihe | Asiakirja | Kuvaus |
| :--- | :--- | :--- |
| 🗄️ **Tietokantaprofiilit & Topologia** | [db-profiles-and-topology.md](db-profiles-and-topology.md) | YAML-profiilihierarkia (`config/profiles/databases/`), porttitopologia ja Sääntö 11. |
| 📑 **Analytics Publisher Asennus** | [publisher-setup.md](publisher-setup.md) | Publisher 2025 asennus, `/xmlpserver`-verkkoliittymä, RCU-skeemat ja tietolähteet. |
| 📑 **Publisher REST API** | [publisher-guide.md](publisher-guide.md) | Pixel Perfect REST API asiakirjojen luonti, luettelon käyttöönotto ja raportointi. |
| 📐 **Oracle Forms 14c Asennus** | [forms-setup.md](forms-setup.md) | Forms Services 14.1.2 asennus, HTML5 noVNC Forms Builder GUI ja modernisointi APEXiin. |
| 🔄 **Forms APEX Migraatio** | [forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md) | Vaiheittainen tiekartta Forms/Reports-sovellusten modernisoimiseksi responsiiviseen APEXiin. |
| 💻 **Verkko-IDE ja CI/CD** | [web-ide-artifactory.md](web-ide-artifactory.md) | VS Code Verkko-IDE (`code-server`), esiasennetut laajennukset ja paikallinen CI (`act`). |
| 🛡️ **Tietoturva ja SSO** | [security.md](security.md) | Zero-Trust -salasananhallinta, Oracle SEPS Wallet, vähimpien oikeuksien roolit ja Azure AD SSO. |
| 🔑 **Oracle Wallet Arkkitehtuuri** | [oracle-wallet-architecture-plan.md](oracle-wallet-architecture-plan.md) | SEPS Auto-Login Wallet, muistipohjainen salasanojen nouto ja automaattinen kierto. |
| 🪟 **Windows Enterprise Asennus** | [windows-enterprise-setup.md](windows-enterprise-setup.md) | Zero-Admin (Non-Root) hiekkalaatikko, PowerShell-luottamusskriptit ja WSL2-optimointi. |
| 📈 **Levytilan Valvonta** | [oracle-free-db-monitoring.md](oracle-free-db-monitoring.md) | Oracle Free 12 GB rajan valvonta, päivittäiset Scheduler-huoltotyöt ja hälytykset. |
| 📉 **Lähtötilan Mittarit** | [oracle-free-db-initial-state.md](oracle-free-db-initial-state.md) | Levytilan ja taulutilojen mitattu alkutila puhtaan asennuksen jälkeen. |
| 📦 **APEX-Sovellusten Käyttöönotto** | [apex-apps-deployment.md](apex-apps-deployment.md) | Pakattujen APEX-sovellusten automatisoitu tuonti hakemistosta `binaries/apex_apps/`. |
| 🌐 **Erillinen ORDS-Palvelin** | [standalone-ords.md](standalone-ords.md) | Erillisen ORDS-palvelimen asennus Linux-palvelimeen ilman Dockeria. |
| 🚀 **Asennustyönkulun Arkkitehtuuri** | [setup-all-workflow.md](setup-all-workflow.md) | Täydellinen työnkulkukaavio, idempotenssi, SQLcl-säilön varajärjestelmä ja Defender-optimoinnit. |
