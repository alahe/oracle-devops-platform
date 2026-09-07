[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📚 Documentation Center & Repository Sitemap

This directory contains technical architecture blueprints, deployment manuals, operational runbooks, and deep-dive specifications for the Oracle DevOps Platform.

---

## 🗺️ Topic Index & Quick Navigation

| Topic | Document | Description |
| :--- | :--- | :--- |
| 💻 **Enterprise Windows & WSL2** | [windows-enterprise-setup-guide.md](windows-enterprise-setup-guide.md) | Zero-Admin WSL2 setup, 10-step dry-run diagnostic engine, Hyper-V ports, and corporate VPN/proxy. |
| 🏢 **Enterprise Onboarding & Mirrors** | [enterprise-onboarding-guide.md](enterprise-onboarding-guide.md) | Corporate Artifactory container mirrors, single-command profile patching, and clean rollback. |
| 🏛️ **Enterprise Distributed 4-Host** | [enterprise-distributed-architecture.md](enterprise-distributed-architecture.md) | 4-host production architecture, active/standby failover, and zero-trust distribution. |
| 📋 **Enterprise Jira Backlog** | [backlog/README.md](backlog/README.md) | 11 user stories, 62 story points delivery roadmap for enterprise distributed rollout. |
| 🔄 **Database Image Switching** | [database-image-switching-guide.md](database-image-switching-guide.md) | FastStart instant images, multi-vendor registry mirrors, and in-container unzipping. |
| 🔄 **3-Tier Lifecycle & Snapshots** | [devops-lifecycle-guide.md](devops-lifecycle-guide.md) | Instant Golden Snapshot recovery (~15s), RMAN backups, and automated disaster recovery. |
| 🧪 **Automated Testing & Dev Hub** | [testing-framework-and-devhub.md](testing-framework-and-devhub.md) | 160+ unit tests, live blueprint validation, dual-stream terminal UX, and Dev Hub architecture. |
| 🚀 **Quick Login & Credentials** | [quick-login-guide.md](quick-login-guide.md) | 1-click clipboard helpers, SEPS wallet credential retrieval, and direct web URLs. |
| 📋 **Architecture Blueprints Matrix** | [../config/blueprints/README.md](../config/blueprints/README.md) | Complete matrix of the 12 canonical blueprints (0..11) from core base to distributed cluster. |
| 🗄️ **Database Profiles & Topology** | [db-profiles-and-topology.md](db-profiles-and-topology.md) | YAML profile hierarchy (`config/profiles/databases/`), non-clashing port topology, and Rule 11 architecture. |
| 📑 **Analytics Publisher Setup** | [publisher-setup.md](publisher-setup.md) | Analytics Publisher 2025 installation, `/xmlpserver` web UI, RCU schema provisioning, and data sources. |
| 📑 **Publisher REST API** | [publisher-guide.md](publisher-guide.md) | Pixel Perfect REST API document generation, catalog deployments, and automated reports distribution. |
| 📑 **Publisher Template Builder** | [publisher-template-builder-guide.md](publisher-template-builder-guide.md) | Designing RTF and Excel templates for Oracle Analytics Publisher document generation. |
| 📐 **Oracle Forms 14c Setup** | [forms-setup.md](forms-setup.md) | Forms Services 14.1.2 installation, HTML5 noVNC Forms Builder GUI, and modernization to APEX. |
| 🔄 **Forms to APEX Migration** | [forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md) | Step-by-step modernization roadmap for converting legacy Oracle Forms/Reports into modern responsive APEX. |
| 💻 **Containerized Web IDE & CI/CD** | [web-ide-artifactory.md](web-ide-artifactory.md) | VS Code Web IDE (`code-server`), pre-bundled extensions, Artifactory mirrors, and local CI runner (`act`). |
| 🛡️ **Security & SSO Architecture** | [security.md](security.md) | Zero-Trust password management, Oracle SEPS Wallet, least-privilege roles, and Azure Entra-ID SSO. |
| 🔑 **Oracle Wallet Architecture** | [oracle-wallet-architecture-plan.md](oracle-wallet-architecture-plan.md) | SEPS Auto-Login Wallet design, JIT in-memory password retrieval, and automated zero-downtime rotation. |
| 🏢 **Artifactory Mirror Setup** | [artifactory-setup.md](artifactory-setup.md) | Corporate JFrog Artifactory container registry and generic repository configuration. |
| 🌐 **ORDS Profiles Lifecycle** | [ords-profiles-lifecycle.md](ords-profiles-lifecycle.md) | Standalone and containerized ORDS connection pools and lifecycle management. |
| 📈 **Storage Monitoring & Maintenance** | [oracle-free-db-monitoring.md](oracle-free-db-monitoring.md) | Oracle Free 12 GB user data ceiling monitoring, daily Scheduler maintenance jobs, and automated alerts. |
| 📉 **Initial Storage Benchmarks** | [oracle-free-db-initial-state.md](oracle-free-db-initial-state.md) | Clean-state storage breakdown after fresh installation and container initialization. |
| 📦 **APEX Applications Deployment** | [apex-apps-deployment.md](apex-apps-deployment.md) | Automated APEX application importing and deployment pipelines from `binaries/apex_apps/`. |
| 🌐 **Standalone ORDS Server** | [standalone-ords.md](standalone-ords.md) | Standalone Oracle REST Data Services deployment on dedicated Linux hosts outside Docker. |
| 🚀 **Setup Workflow Architecture** | [setup-all-workflow.md](setup-all-workflow.md) | Complete flowchart, idempotency contracts, SQLcl container fallback, and Microsoft Defender optimizations. |
