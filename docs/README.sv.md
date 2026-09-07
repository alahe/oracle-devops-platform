[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📚 Dokumentationscenter & webbplatskarta

Denna katalog innehåller tekniska specifikationer, installationsguider och arkitekturöversikter för Oracle DevOps-plattformen.

---

## 🗺️ Ämnesträd & snabblänkar

| Ämne | Dokument | Beskrivning |
| :--- | :--- | :--- |
| 💻 **Företagsguide för Windows och WSL2** | [windows-enterprise-setup-guide.md](windows-enterprise-setup-guide.md) | Zero-Admin WSL2-installation, 10-stegs dry-run diagnostikmotor, Hyper-V-portar och proxy. |
| 🏢 **Företags onboarding och registerpeglar** | [enterprise-onboarding-guide.md](enterprise-onboarding-guide.md) | Konfiguration av Artifactory-registerpeglar, automatiserad profiluppdatering och återställning. |
| 🏛️ **Distribuerad 4-serverarkitektur** | [enterprise-distributed-architecture.md](enterprise-distributed-architecture.md) | 4-server produktionsarkitektur, active/standby redundans och zero-trust säkerhet. |
| 📋 **Företags Jira backlog** | [backlog/README.md](backlog/README.md) | 11 användarberättelser, 62 story points färdplan för distribuerad utrullning. |
| 🔄 **Byte av databascontaineravbilder** | [database-image-switching-guide.md](database-image-switching-guide.md) | FastStart snabbavbilder, registerpeglar och uppackning i containern. |
| 🔄 **3-nivåers livscykel och ögonblicksbilder** | [devops-lifecycle-guide.md](devops-lifecycle-guide.md) | Gyllene ögonblicksbilder (~15s återställning), RMAN-backuper och katastrofåterställning. |
| 🧪 **Automatiserad testning och Dev Hub** | [testing-framework-and-devhub.md](testing-framework-and-devhub.md) | 160+ enhetstester, realtidsvalidering av blueprints och Dev Hub. |
| 🚀 **Snabbguide för inloggning** | [quick-login-guide.md](quick-login-guide.md) | 1-klicks urklippshjälpare, SEPS Wallet lösenordshämtning och webblänkar. |
| 📋 **Arkitektur blueprints matris** | [../config/blueprints/README.md](../config/blueprints/README.md) | Jämförelse av 12 kanoniska arkitekturmodeller (0..11) och resurskrav. |
| 🗄️ **Databasprofiler och topologi** | [db-profiles-and-topology.md](db-profiles-and-topology.md) | YAML-profilhierarki (`config/profiles/databases/`), porttopologi och Regel 11. |
| 📑 **Analytics Publisher installation** | [publisher-setup.md](publisher-setup.md) | Publisher 2025 installation, webbgränssnitt (`/xmlpserver`), RCU-scheman och datakällor. |
| 📑 **Publisher REST API** | [publisher-guide.md](publisher-guide.md) | Pixel Perfect REST API dokumentskapande och automatiserad distribution. |
| 📑 **Publisher mallbyggare** | [publisher-template-builder-guide.md](publisher-template-builder-guide.md) | Designa RTF- och Excel-mallar för Analytics Publisher-rapportering. |
| 📐 **Oracle Forms 14c installation** | [forms-setup.md](forms-setup.md) | Forms Services 14.1.2 installation, HTML5 noVNC Forms Builder GUI och modernisering till APEX. |
| 🔄 **Forms -> APEX modernisering** | [forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md) | Steg-för-steg färdplan för att flytta Forms/Reports till modern APEX. |
| 💻 **Web IDE och CI/CD** | [web-ide-artifactory.md](web-ide-artifactory.md) | VS Code Web IDE (`code-server`), förinstallerade tillägg och lokal CI (`act`). |
| 🛡️ **Säkerhet och SSO** | [security.md](security.md) | Zero-Trust lösenordshantering, Oracle SEPS Wallet och Azure Entra-ID SSO. |
| 🔑 **Oracle Wallet arkitektur** | [oracle-wallet-architecture-plan.md](oracle-wallet-architecture-plan.md) | SEPS Auto-Login Wallet, minnesbaserad lösenordshämtning och automatisk rotation. |
| 🏢 **Artifactory installation** | [artifactory-setup.md](artifactory-setup.md) | Konfiguration av företags JFrog Artifactory containerregister och arkiv. |
| 🌐 **ORDS profiler och livscykel** | [ords-profiles-lifecycle.md](ords-profiles-lifecycle.md) | Fristående och containerbaserade ORDS-anslutningspooler. |
| 📈 **Lagringsövervakning** | [oracle-free-db-monitoring.md](oracle-free-db-monitoring.md) | Övervakning av Oracle Free 12 GB-taket och automatiska larm. |
| 📉 **Inledande lagringsriktmärken** | [oracle-free-db-initial-state.md](oracle-free-db-initial-state.md) | Resursförbrukning direkt efter nyinstallation och containerinitialisering. |
| 📦 **APEX applikationsdistribution** | [apex-apps-deployment.md](apex-apps-deployment.md) | Automatisk import av paketerade APEX-appar från `binaries/apex_apps/`. |
| 🌐 **Fristående ORDS-server** | [standalone-ords.md](standalone-ords.md) | Installation av fristående Oracle REST Data Services på Linux utanför Docker. |
| 🚀 **Installationsflödets arkitektur** | [setup-all-workflow.md](setup-all-workflow.md) | Komplett flödesdiagram, idempotens och Defender-optimeringar. |
