[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📚 Dokumentācijas centrs & vietnes karte

Šis katalogs satur Oracle DevOps platformas tehniskās specifikācijas, instalēšanas rokasgrāmatas un arhitektūras pārskatus.

---

## 🗺️ Tēmu koks & ātrās saites

| Tēma | Dokuments | Apraksts |
| :--- | :--- | :--- |
| 💻 **Uzņēmuma Windows un WSL2** | [windows-enterprise-setup-guide.md](windows-enterprise-setup-guide.md) | Zero-Admin WSL2 iestatīšana, 10 soļu dry-run diagnostika, Hyper-V porti un korporatīvais starpniekserveris. |
| 🏢 **Uzņēmuma onboarding un spoguļi** | [enterprise-onboarding-guide.md](enterprise-onboarding-guide.md) | Artifactory reģistru spoguļu konfigurēšana, profilu automatizēta pielāgošana un atjaunošana. |
| 🏛️ **Sadalītā 4 resursdatoru arhitektūra** | [enterprise-distributed-architecture.md](enterprise-distributed-architecture.md) | 4 resursdatoru ražošanas arhitektūra, active/standby pārslēgšanās un zero-trust drošība. |
| 📋 **Uzņēmuma Jira backlog** | [backlog/README.md](backlog/README.md) | 11 lietotāju stāsti, 62 stāstu punkti sadalītās ieviešanas ceļvedī. |
| 🔄 **Datubāzes konteineru attēlu pārslēgšana** | [database-image-switching-guide.md](database-image-switching-guide.md) | FastStart ātrie attēli, reģistru spoguļi un atpakošana konteinerā. |
| 🔄 **3 līmeņu dzīvescikls un momentuzņēmumi** | [devops-lifecycle-guide.md](devops-lifecycle-guide.md) | Zelta momentuzņēmumu tūlītēja atjaunošana (~15s), RMAN rezerves kopijas un avārijas atjaunošana. |
| 🧪 **Automatizētā testēšana un Dev Hub** | [testing-framework-and-devhub.md](testing-framework-and-devhub.md) | 160+ automatizētie testi, plānu reāllaika validācija un Dev Hub. |
| 🚀 **Ātrās pieteikšanās rokasgrāmata** | [quick-login-guide.md](quick-login-guide.md) | 1 klikšķa starpliktuves palīgi, SEPS Wallet akreditācijas datu ieguve un tīmekļa saites. |
| 📋 **Arhitektūras plānu matrica** | [../config/blueprints/README.md](../config/blueprints/README.md) | 12 kanonisko arhitektūras modeļu (0..11) salīdzinājums un resursu prasības. |
| 🗄️ **Datubāzu profili un topoloģija** | [db-profiles-and-topology.md](db-profiles-and-topology.md) | YAML profilu hierarhija (`config/profiles/databases/`), portu topoloģija un Noteikums 11. |
| 📑 **Analytics Publisher uzstādīšana** | [publisher-setup.md](publisher-setup.md) | Publisher 2025 uzstādīšana, tīmekļa saskarne (`/xmlpserver`), RCU shēmas un datu avoti. |
| 📑 **Publisher REST API** | [publisher-guide.md](publisher-guide.md) | Pixel Perfect REST API dokumentu ģenerēšana un automatizēta atskaišu izplatīšana. |
| 📑 **Publisher veidņu veidotājs** | [publisher-template-builder-guide.md](publisher-template-builder-guide.md) | RTF un Excel veidņu izstrāde Analytics Publisher atskaitēm. |
| 📐 **Oracle Forms 14c uzstādīšana** | [forms-setup.md](forms-setup.md) | Forms Services 14.1.2 instalēšana, HTML5 noVNC Forms Builder GUI un modernizācija uz APEX. |
| 🔄 **Forms -> APEX modernizācija** | [forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md) | Pakāpenisks ceļvedis Forms/Reports risinājumu modernizēšanai uz APEX. |
| 💻 **Web IDE un CI/CD** | [web-ide-artifactory.md](web-ide-artifactory.md) | VS Code Web IDE (`code-server`), iepriekš instalētie paplašinājumi un lokālais CI (`act`). |
| 🛡️ **Drošība un SSO** | [security.md](security.md) | Zero-Trust paroļu pārvaldība, Oracle SEPS Wallet un Azure Entra-ID SSO. |
| 🔑 **Oracle Wallet arhitektūra** | [oracle-wallet-architecture-plan.md](oracle-wallet-architecture-plan.md) | SEPS Auto-Login Wallet, uz atmiņu balstīta paroļu nolasīšana un automātiskā rotācija. |
| 🏢 **Artifactory spoguļu iestatīšana** | [artifactory-setup.md](artifactory-setup.md) | Uzņēmuma JFrog Artifactory konteineru reģistra un krātuvju konfigurēšana. |
| 🌐 **ORDS profili un dzīvescikls** | [ords-profiles-lifecycle.md](ords-profiles-lifecycle.md) | Savrupi un konteinerizēti ORDS savienojumu pūli. |
| 📈 **Diska vietas uzraudzība** | [oracle-free-db-monitoring.md](oracle-free-db-monitoring.md) | Oracle Free 12 GB limita uzraudzība un automatizēti brīdinājumi. |
| 📉 **Sākotnējie etaloni** | [oracle-free-db-initial-state.md](oracle-free-db-initial-state.md) | Tīras instalācijas resursu un tabultelpu izlietojums. |
| 📦 **APEX lietotņu izvietošana** | [apex-apps-deployment.md](apex-apps-deployment.md) | Automatizēta APEX lietotņu importēšana no `binaries/apex_apps/`. |
| 🌐 **Savrups ORDS serveris** | [standalone-ords.md](standalone-ords.md) | Savrupa Oracle REST Data Services servera izvietošana Linux vidē ārpus Docker. |
| 🚀 **Uzstādīšanas plūsmas arhitektūra** | [setup-all-workflow.md](setup-all-workflow.md) | Pilna blokshēma, idempotence un Defender optimizācija. |
| ❓ **Platformas BUJ (Visi jautājumi)** | [lv/faq.md](lv/faq.md) | Vienota zināšanu bāze iesācējiem, arhitektūrai un problēmu novēršanai. |
| 🏛️ **Oracle resursi un lejupielādes** | [lv/oracle-resources-and-downloads.md](lv/oracle-resources-and-downloads.md) | Oficiālie Oracle Container Registry (OCR) attēli, lejupielādes un portāli. |
