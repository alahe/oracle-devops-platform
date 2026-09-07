[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📚 Documentation Center & Repository Sitemap

This directory contains technical architecture blueprints, deployment manuals, operational runbooks, and deep-dive specifications for the Oracle DevOps Platform.

---

## 🗺️ Topic Index & Quick Navigation

| Topic | Document | Description |
| :--- | :--- | :--- |
| 🗄️ **Database Profiles & Topology** | [db-profiles-and-topology.md](db-profiles-and-topology.md) | YAML profile hierarchy (`config/profiles/databases/`), non-clashing port topology, and Rule 11 architecture. |
| 📑 **Analytics Publisher Setup** | [publisher-setup.md](publisher-setup.md) | Analytics Publisher 2025 installation, `/xmlpserver` web UI, RCU schema provisioning, and data sources. |
| 📑 **Publisher REST API** | [publisher-guide.md](publisher-guide.md) | Pixel Perfect REST API document generation, catalog deployments, and automated reports distribution. |
| 📐 **Oracle Forms 14c Setup** | [forms-setup.md](forms-setup.md) | Forms Services 14.1.2 installation, HTML5 noVNC Forms Builder GUI, and modernization to APEX. |
| 🔄 **Forms to APEX Migration** | [forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md) | Step-by-step modernization roadmap for converting legacy Oracle Forms/Reports into modern responsive APEX. |
| 💻 **Containerized Web IDE & CI/CD** | [web-ide-artifactory.md](web-ide-artifactory.md) | VS Code Web IDE (`code-server`), pre-bundled extensions, Artifactory mirrors, and local CI runner (`act`). |
| 🛡️ **Security & SSO Architecture** | [security.md](security.md) | Zero-Trust password management, Oracle SEPS Wallet, least-privilege roles, and Azure Entra-ID SSO. |
| 🔑 **Oracle Wallet Architecture** | [oracle-wallet-architecture-plan.md](oracle-wallet-architecture-plan.md) | SEPS Auto-Login Wallet design, JIT in-memory password retrieval, and automated zero-downtime rotation. |
| 🪟 **Windows Enterprise Setup** | [windows-enterprise-setup.md](windows-enterprise-setup.md) | Zero-Admin (Non-Root) sandbox setup, PowerShell trust scripts, and WSL2 Podman optimization. |
| 📈 **Storage Monitoring & Maintenance** | [oracle-free-db-monitoring.md](oracle-free-db-monitoring.md) | Oracle Free 12 GB user data ceiling monitoring, daily Scheduler maintenance jobs, and automated alerts. |
| 📉 **Initial Storage Benchmarks** | [oracle-free-db-initial-state.md](oracle-free-db-initial-state.md) | Clean-state storage breakdown after fresh installation and container initialization. |
| 📦 **APEX Applications Deployment** | [apex-apps-deployment.md](apex-apps-deployment.md) | Automated APEX application importing and deployment pipelines from `binaries/apex_apps/`. |
| 🌐 **Standalone ORDS Server** | [standalone-ords.md](standalone-ords.md) | Standalone Oracle REST Data Services deployment on dedicated Linux hosts outside Docker. |
| 🚀 **Setup Workflow Architecture** | [setup-all-workflow.md](setup-all-workflow.md) | Complete flowchart, idempotency contracts, SQLcl container fallback, and Microsoft Defender optimizations. |
