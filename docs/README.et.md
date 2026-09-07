[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📚 Dokumentatsiooni keskus & sisukord (sitemap)

See kataloog sisaldab Oracle DevOps platvormi tehnilisi spetsifikatsioone, paigaldusjuhendeid ja arhitektuurseid ülevaateid.

---

## 🗺️ Teemade puu & kiirlingid

| Valdkond | Dokument | Kirjeldus |
| :--- | :--- | :--- |
| 💻 **Ettevõtte Windows ja WSL2** | [windows-enterprise-setup-guide.md](windows-enterprise-setup-guide.md) | Zero-Admin WSL2 seadistus, 10-astmeline dry-run diagnostika, Hyper-V pordid ja korporatiivne proxy. |
| 🏢 **Ettevõtte onboarding ja peeglid** | [enterprise-onboarding-guide.md](enterprise-onboarding-guide.md) | Artifactory registripeeglite seadistamine, profiilide automaatne kohandamine ja taastamine. |
| 🏛️ **Hajutatud 4-serveriline arhitektuur** | [enterprise-distributed-architecture.md](enterprise-distributed-architecture.md) | 4-serveriline toodanguarhitektuur, active/standby failover ja zero-trust turvalisus. |
| 📋 **Ettevõtte Jira backlog** | [backlog/README.et.md](backlog/README.et.md) | 11 kasutajalugu, 62 story pointi hajutatud toodangupaigalduse teekaardil. |
| 🔄 **Konteineripiltide vahetamine** | [database-image-switching-guide.md](database-image-switching-guide.md) | FastStart kiirpildid, registripeeglid ja konteinerisisene lahtipakkimine. |
| 🔄 **3-tasemeline elutsükkel ja hetktõmmised** | [devops-lifecycle-guide.md](devops-lifecycle-guide.md) | Kuldsete hetktõmmiste taastamine (~15s), RMAN varukoopiad ja katastroofijärgne taaste. |
| 🧪 **Automaattestimine ja Dev Hub** | [testing-framework-and-devhub.md](testing-framework-and-devhub.md) | 160+ automaattesti, reaalajas kavandite valideerimine ja Dev Hubi arhitektuur. |
| 🚀 **Kiirjuhend sisselogimiseks** | [quick-login-guide.md](quick-login-guide.md) | 1-kliki lõikelaua abivahendid, SEPS Wallet paroolide pärimine ja veebilingid. |
| 📋 **Arhitektuursete kavandite maatriks** | [../config/blueprints/README.et.md](../config/blueprints/README.et.md) | 12 kanoonilise arhitektuurikavandi (0..11) võrdlus ja ressursinõuded. |
| 🗄️ **Andmebaasi profiilid** | [db-profiles-and-topology.md](db-profiles-and-topology.md) | YAML profiilide hierarhia (`config/profiles/databases/`), mittepõrkuv portide topoloogia ja Reegel 11. |
| 📑 **Analytics Publisheri paigaldus** | [publisher-setup.md](publisher-setup.md) | Publisher 2025 paigaldus, veebiliides (`/xmlpserver`), RCU skeemid ja andmeallikad. |
| 📑 **Publisher REST API** | [publisher-guide.md](publisher-guide.md) | Pixel Perfect REST API dokumentide genereerimine, kataloogi tarne ja automatiseeritud aruanded. |
| 📑 **Publisher mallide kujundamine** | [publisher-template-builder-guide.md](publisher-template-builder-guide.md) | RTF ja Exceli mallide kujundamine Analytics Publisheri aruannete loomiseks. |
| 📐 **Oracle Forms 14c paigaldus** | [forms-setup.md](forms-setup.md) | Forms Services 14.1.2 paigaldus, HTML5 noVNC Forms Builder GUI ja moderniseerimine APEX-iks. |
| 🔄 **Forms -> APEX migratsioon** | [forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md) | Samm-sammuline teekaart Forms/Reports rakenduste viimiseks kaasaegsesse APEX keskkonda. |
| 💻 **Veebi-IDE ja CI/CD** | [web-ide-artifactory.md](web-ide-artifactory.md) | VS Code Veebi-IDE (`code-server`), eelpaigaldatud laiendused ja lokaalne CI (`act`). |
| 🛡️ **Turvalisus ja SSO** | [security.md](security.md) | Zero-Trust paroolihaldus, Oracle SEPS Wallet, vähimate õiguste rollid ja Azure Entra-ID SSO. |
| 🔑 **Oracle Wallet arhitektuur** | [oracle-wallet-architecture-plan.md](oracle-wallet-architecture-plan.md) | SEPS Auto-Login Wallet, mälupõhine paroolide pärimine ja automaatne rotatsioon. |
| 🏢 **Artifactory peeglite seadistus** | [artifactory-setup.md](artifactory-setup.md) | Ettevõtte JFrog Artifactory konteinerregistri ja repositooriumide konfiguratsioon. |
| 🌐 **ORDS profiilid ja elutsükkel** | [ords-profiles-lifecycle.md](ords-profiles-lifecycle.md) | Eraldiseisvad ja konteineriseeritud ORDS ühenduste basseinid. |
| 📈 **Kettamahu monitooring** | [oracle-free-db-monitoring.md](oracle-free-db-monitoring.md) | Oracle Free 12 GB limiidi jälgimine, igapäevased hoolduse Scheduler Jobid ja hoiatused. |
| 📉 **Algseisu mõõdikud** | [oracle-free-db-initial-state.md](oracle-free-db-initial-state.md) | Puhas paigaldusjärgne kettamahu ja tabeliruumide kasutus. |
| 📦 **APEX rakenduste tarne** | [apex-apps-deployment.md](apex-apps-deployment.md) | Pakendatud APEX rakenduste automaatne importimine kaustast `binaries/apex_apps/`. |
| 🌐 **Eraldiseisev ORDS server** | [standalone-ords.md](standalone-ords.md) | Eraldiseisva Oracle REST Data Services serveri paigaldus Linux masinasse väljaspool Dockerit. |
| 🚀 **Paigaldusvoo arhitektuur** | [setup-all-workflow.md](setup-all-workflow.md) | Täielik voodiagramm, idempotentsus, SQLcl container fallback ja Defenderi optimeeringud. |
