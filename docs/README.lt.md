[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📚 Dokumentacijos centras & svetainės medis

Šis katalogas apima Oracle DevOps platformos technines specifikacijas, diegimo vadovus ir architektūros apžvalgas.

---

## 🗺️ Temų medis & greitosios nuorodos

| Tema | Dokumentas | Aprašymas |
| :--- | :--- | :--- |
| 💻 **Įmonės Windows ir WSL2** | [windows-enterprise-setup-guide.md](windows-enterprise-setup-guide.md) | Zero-Admin WSL2 sąranka, 10 žingsnių dry-run diagnostika, Hyper-V prievadai ir įgaliotasis serveris. |
| 🏢 **Įmonės onboarding ir veidrodžiai** | [enterprise-onboarding-guide.md](enterprise-onboarding-guide.md) | Artifactory registrų veidrodžių konfigūravimas, profilių automatizuotas pritaikymas ir atkūrimas. |
| 🏛️ **Paskirstyta 4 mazgų architektūra** | [enterprise-distributed-architecture.md](enterprise-distributed-architecture.md) | 4 mazgų gamybinė architektūra, active/standby perjungimas ir zero-trust saugumas. |
| 📋 **Įmonės Jira backlog** | [backlog/README.md](backlog/README.md) | 11 naudotojų istorijų, 62 istorijų taškai paskirstyto diegimo gairėse. |
| 🔄 **Duomenų bazės atvaizdų keitimas** | [database-image-switching-guide.md](database-image-switching-guide.md) | FastStart spartieji atvaizdai, registrų veidrodžiai ir išpakavimas konteineryje. |
| 🔄 **3 lygmenų gyvavimo ciklas ir kopijos** | [devops-lifecycle-guide.md](devops-lifecycle-guide.md) | Auksinių momentinių kopijų atkūrimas (~15s), RMAN atsarginės kopijos ir atkūrimas po avarijos. |
| 🧪 **Automatizuotas testavimas ir Dev Hub** | [testing-framework-and-devhub.md](testing-framework-and-devhub.md) | 160+ automatizuotų testų, planų tikrinimas realiuoju laiku ir Dev Hub. |
| 🚀 **Greito prisijungimo gidas** | [quick-login-guide.md](quick-login-guide.md) | 1 paspaudimo iškarpinės įrankiai, SEPS Wallet kredencialų gavimas ir tiesioginės nuorodos. |
| 📋 **Architektūros planų matrica** | [../config/blueprints/README.md](../config/blueprints/README.md) | 12 kanoninių architektūros modelių (0..11) palyginimas ir išteklių reikalavimai. |
| 🗄️ **Duomenų bazių profiliai ir topologija** | [db-profiles-and-topology.md](db-profiles-and-topology.md) | YAML profilių hierarchija (`config/profiles/databases/`), prievadų topologija ir Taisyklė 11. |
| 📑 **Analytics Publisher diegimas** | [publisher-setup.md](publisher-setup.md) | Publisher 2025 diegimas, žiniatinklio sąsaja (`/xmlpserver`), RCU schemos ir duomenų šaltiniai. |
| 📑 **Publisher REST API** | [publisher-guide.md](publisher-guide.md) | Pixel Perfect REST API dokumentų generavimas ir automatizuotas ataskaitų platinimas. |
| 📑 **Publisher šablonų kūrimas** | [publisher-template-builder-guide.md](publisher-template-builder-guide.md) | RTF ir Excel šablonų kūrimas Analytics Publisher ataskaitoms. |
| 📐 **Oracle Forms 14c diegimas** | [forms-setup.md](forms-setup.md) | Forms Services 14.1.2 diegimas, HTML5 noVNC Forms Builder GUI ir modernizavimas į APEX. |
| 🔄 **Forms -> APEX modernizavimas** | [forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md) | Nuoseklus planas, kaip perkelti pasenusias Forms/Reports sistemas į modernią APEX aplinką. |
| 💻 **Web IDE ir CI/CD** | [web-ide-artifactory.md](web-ide-artifactory.md) | VS Code Web IDE (`code-server`), integruoti plėtiniai ir vietinis CI (`act`). |
| 🛡️ **Saugumas ir SSO** | [security.md](security.md) | Zero-Trust slaptažodžių valdymas, Oracle SEPS Wallet ir Azure Entra-ID SSO. |
| 🔑 **Oracle Wallet architektūra** | [oracle-wallet-architecture-plan.md](oracle-wallet-architecture-plan.md) | SEPS Auto-Login Wallet, slaptažodžių gavimas iš atminties ir automatinis keitimas. |
| 🏢 **Artifactory veidrodžių sąranka** | [artifactory-setup.md](artifactory-setup.md) | Įmonės JFrog Artifactory konteinerių registro ir saugyklų konfigūravimas. |
| 🌐 **ORDS profiliai ir gyvavimo ciklas** | [ords-profiles-lifecycle.md](ords-profiles-lifecycle.md) | Atskiri ir konteinerizuoti ORDS jungčių telkiniai. |
| 📈 **Disko vietos stebėjimas** | [oracle-free-db-monitoring.md](oracle-free-db-monitoring.md) | Oracle Free 12 GB ribos stebėjimas ir automatiniai įspėjimai. |
| 📉 **Pradiniai etalonai** | [oracle-free-db-initial-state.md](oracle-free-db-initial-state.md) | Švarios sistemos disko vietos ir lentelių erdvių panaudojimas po diegimo. |
| 📦 **APEX programų diegimas** | [apex-apps-deployment.md](apex-apps-deployment.md) | Automatizuotas APEX programų importavimas iš `binaries/apex_apps/`. |
| 🌐 **Atskiras ORDS mazgas** | [standalone-ords.md](standalone-ords.md) | Atskiro Oracle REST Data Services serverio diegimas Linux aplinkoje be Docker konteinerio. |
| 🚀 **Diegimo eigos architektūra** | [setup-all-workflow.md](setup-all-workflow.md) | Išsami blokschemų seka, idempotentumas ir Defender optimizavimai. |
| ❓ **Platformos DUK (Visi klausimai)** | [lt/faq.md](lt/faq.md) | Vieninga žinių bazė pradedantiesiems, architektūrai ir trikčių šalinimui. |
| 🏛️ **Oracle ištekliai ir atsisiuntimai** | [lt/oracle-resources-and-downloads.md](lt/oracle-resources-and-downloads.md) | Oficialūs Oracle Container Registry (OCR) atvaizdai, atsisiuntimai ir portalai. |
