# Official Oracle Resources & Container Images

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/oracle-resources-and-downloads.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/oracle-resources-and-downloads.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/oracle-resources-and-downloads.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/oracle-resources-and-downloads.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/oracle-resources-and-downloads.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/oracle-resources-and-downloads.md)

> Curated index of official Oracle Container Registry (OCR) images, product downloads, documentation portals, community forums, and learning repositories.

---

**Jump to section:** [Container Registry Images](#containers) • [Official Product Downloads](#downloads) • [Documentation & Cloud Portals](#portals) • [Community, Forums & Events](#community) • [Hands-on Labs & Repositories](#learning)

---

<a id="containers"></a>
## Container Registry Images

### Oracle Database 23ai Free `[OCR Official]`
- **Description:** Official Oracle 23ai Free database container image featuring AI Vector Search, JSON-Relational Duality, and PDB support.
- **Project Role:** Foundation database layer for local development, CI/CD pipelines, and automated test runners.
- **Official Link:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Ffree](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Ffree)
- **Download / CLI Command:**
  ```bash
  podman pull container-registry.oracle.com/database/free:latest
  ```

### Oracle REST Data Services (ORDS) `[OCR Official]`
- **Description:** Prebuilt, certified standalone ORDS container delivering AutoREST APIs, APEX static resource routing, and OAuth2 security.
- **Project Role:** Zero-footprint web application listener bridging HTTPS traffic to Pluggable Databases.
- **Official Link:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fords](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fords)
- **Download / CLI Command:**
  ```bash
  podman pull container-registry.oracle.com/database/ords:latest
  ```

### Oracle SQLcl CLI Container `[OCR Official]`
- **Description:** Official ephemeral SQLcl container image providing Java 21 runtime, Liquibase schema orchestration, and APEXlang compiler.
- **Project Role:** Enables zero-local-install execution (Rule 4) in locked-down or zero-admin corporate workstations.
- **Official Link:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fsqlcl](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:database%2Fsqlcl)
- **Download / CLI Command:**
  ```bash
  podman pull container-registry.oracle.com/database/sqlcl:latest
  ```

### Oracle Container Registry (OCR) Portal `[OCR Portal]`
- **Description:** Central portal and registry catalog for certified, prebuilt Oracle container images with enterprise SLA.
- **Project Role:** Accepting terms of use (Standard Terms of Acceptance) and exploring official Oracle enterprise images.
- **Official Link:** [https://container-registry.oracle.com/](https://container-registry.oracle.com/)
- **Download / CLI Command:**
  ```bash
  podman login container-registry.oracle.com
  ```

### Oracle Linux 9 Slim `[OCR Base]`
- **Description:** Minimal footprint enterprise Linux base image with enterprise security patches and glibc compatibility.
- **Project Role:** Base layer for custom application extensions and developer toolchains.
- **Official Link:** [https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:os%2Foraclelinux](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:4:P4_REPOSITORY:os%2Foraclelinux)
- **Download / CLI Command:**
  ```bash
  podman pull container-registry.oracle.com/os/oraclelinux:9-slim
  ```

### Oracle Database Free FastStart Containers (gvenzl) `[Docker Hub / GitHub]`
- **Description:** Popular Oracle Database Free container images by Gerald Venzl featuring instant FastStart boot (~10s) and multi-architecture AMD64/ARM64 support.
- **Project Role:** High-speed developer workflows, Apple Silicon native testing, and FastStart pre-seeded databases.
- **Official Link:** [https://github.com/gvenzl/oci-oracle-free](https://github.com/gvenzl/oci-oracle-free)
- **Download / CLI Command:**
  ```bash
  podman pull docker.io/gvenzl/oracle-free:23-full-faststart
  ```

### Oracle Forms & Reports 14c Container `[Docker Hub]`
- **Description:** Fully pre-configured Oracle Forms 14c container with WebLogic Server, HTML5 noVNC Forms Builder GUI, and compiler.
- **Project Role:** Blueprint 6 & 7: Modernization, headless compilation, and legacy migration to APEX.
- **Official Link:** [https://hub.docker.com/r/allanlahe/oracle-forms](https://hub.docker.com/r/allanlahe/oracle-forms)
- **Download / CLI Command:**
  ```bash
  podman pull docker.io/allanlahe/oracle-forms:14.1.2
  ```

### Oracle Analytics Publisher Container `[Docker Hub]`
- **Description:** Enterprise pixel-perfect reporting engine container pre-patched with OPatch security updates and PDF generator.
- **Project Role:** Blueprint 4 & 5: High-volume document creation, invoice generation, and report deployment.
- **Official Link:** [https://hub.docker.com/r/allanlahe/oracle-publisher](https://hub.docker.com/r/allanlahe/oracle-publisher)
- **Download / CLI Command:**
  ```bash
  podman pull docker.io/allanlahe/oracle-publisher:latest
  ```

<a id="downloads"></a>
## Official Product Downloads

### Oracle APEX Downloads `[Official Download]`
- **Description:** Latest official distribution archive containing complete APEX application schemas, runtime engines, and static images.
- **Project Role:** Automated in-container installation by install-apex.sh into Proxy DB without host unpacking.
- **Official Link:** [https://www.oracle.com/tools/downloads/apex-downloads.html](https://www.oracle.com/tools/downloads/apex-downloads.html)
- **Download / CLI Command:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/apex/apex-latest.zip
  ```

### Oracle REST Data Services (ORDS) Downloads `[Official Download]`
- **Description:** Official standalone ORDS binaries for custom host configurations or embedded application setups.
- **Project Role:** Alternative host-native installation via install-ords-standalone.sh.
- **Official Link:** [https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html](https://www.oracle.com/database/technologies/appdev/rest-data-services-downloads.html)
- **Download / CLI Command:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/java/ords/ords-latest.zip
  ```

### Oracle SQLcl Standalone Download `[Official Download]`
- **Description:** Modern command-line interface for Oracle Database featuring inline auto-completion, Liquibase, and APEX export tools.
- **Project Role:** Standard command-line client for developer workstations across macOS, Linux, and Windows.
- **Official Link:** [https://www.oracle.com/database/sqldev/technologies/sqlcl/download/](https://www.oracle.com/database/sqldev/technologies/sqlcl/download/)
- **Download / CLI Command:**
  ```bash
  curl -LO https://download.oracle.com/otn_software/java/sqldev/sqlcl-latest.zip
  ```

### Oracle Analytics Publisher Software & Template Builder `[Official Download]`
- **Description:** Official downloads page for Oracle Analytics Publisher Desktop Template Builder (Word/Excel add-in) and enterprise server binaries.
- **Project Role:** Installing MS Word Template Builder for designing pixel-perfect RTF/PDF report layouts.
- **Official Link:** [https://www.oracle.com/middleware/technologies/analytics-publisher/downloads.html](https://www.oracle.com/middleware/technologies/analytics-publisher/downloads.html)

### Oracle Instant Client (Basic & SDK) `[Official Download]`
- **Description:** High-performance native client libraries required by Python (python-oracledb), Node.js, and C/C++ applications.
- **Project Role:** Direct native driver mode (Thick driver) and legacy client connectivity.
- **Official Link:** [https://www.oracle.com/database/technologies/instant-client/downloads.html](https://www.oracle.com/database/technologies/instant-client/downloads.html)
- **Download / CLI Command:**
  ```bash
  # Select package for macOS (ARM64/x86), Linux, or Windows
  ```

### Oracle SQL Developer for VS Code `[VS Code Marketplace]`
- **Description:** Official Visual Studio Code extension providing SQL worksheet, object navigator, embedded SQLcl, and connection manager.
- **Project Role:** Integrated IDE environment configured automatically via register-connections.sh.
- **Official Link:** [https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer)
- **Download / CLI Command:**
  ```bash
  code --install-extension Oracle.sql-developer
  ```

<a id="portals"></a>
## Documentation & Cloud Portals

### Oracle Database Free Home & Features `[Product Overview]`
- **Description:** Official product landing page with complete technical specifications, hardware resource limits (2 CPU, 2 GB RAM, 12 GB user data), and FAQ.
- **Project Role:** Reviewing licensing rules, production usage allowances, and resource boundaries.
- **Official Link:** [https://www.oracle.com/database/free/](https://www.oracle.com/database/free/)

### Oracle APEX 26.1 APEXlang Specification `[Language Spec]`
- **Description:** Official language reference and grammar specification for Oracle APEXlang declarative application definition DSL (.apx).
- **Project Role:** Grammar reference for APEXlang DSL generators, AI coding prompts, and declarative app compilation.
- **Official Link:** [https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/?component=app](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/?component=app)

### Oracle Architecture Center Technology Catalog `[Architecture Center]`
- **Description:** Curated catalog of reference architectures, blueprints, deployment topologies, and enterprise solution playbooks.
- **Project Role:** Architectural alignment for hybrid cloud, multi-database LIS topology, and zero-trust deployments.
- **Official Link:** [https://apexadb.oracle.com/ords/r/tech/catalog/home](https://apexadb.oracle.com/ords/r/tech/catalog/home)

### Oracle Forms 14c (14.1.2) Documentation `[Technical Docs]`
- **Description:** Complete documentation suite covering Oracle Forms 14c deployment, WebLogic configuration, and modern web integration.
- **Project Role:** Reference documentation for Blueprint 6 & 7 (Forms container lifecycle, FMX compiler parameters, and APEX migration).
- **Official Link:** [https://docs.oracle.com/en/middleware/developer-tools/forms/14.1.2/index.html](https://docs.oracle.com/en/middleware/developer-tools/forms/14.1.2/index.html)

### Oracle Analytics Server & Publisher Documentation `[Technical Docs]`
- **Description:** Official technical documentation library for Oracle Analytics Server (OAS), Publisher engine, XML data models, and REST APIs.
- **Project Role:** Configuring Blueprint 4 & 5 (Catalog management, WebLogic EmbeddedLDAP security, and automated report scheduling).
- **Official Link:** [https://docs.oracle.com/en/middleware/bi/analytics-server/index.html](https://docs.oracle.com/en/middleware/bi/analytics-server/index.html)

### Oracle REST Data Services (ORDS) Product Center `[Product Overview]`
- **Description:** Product overview, architecture blueprints, feature highlights, and enterprise REST enablement resources for Oracle Database.
- **Project Role:** Deep-dive into ORDS OAuth2 architecture, AutoREST capabilities, and secure API gateways.
- **Official Link:** [https://www.oracle.com/database/technologies/appdev/rest.html](https://www.oracle.com/database/technologies/appdev/rest.html)

### Oracle Cloud Console (OCI) `[Cloud Portal]`
- **Description:** Web management console for Oracle Cloud Infrastructure, Autonomous Database (ADB), compartments, and API keys.
- **Project Role:** Target cloud environment for Blueprints 10 & 11 (Hybrid Cloud & Multi-Region).
- **Official Link:** [https://cloud.oracle.com](https://cloud.oracle.com)

### Oracle Live SQL `[Interactive Learning]`
- **Description:** Free, browser-based interactive sandbox for testing SQL queries, 23ai features, schemas, and tutorials.
- **Project Role:** Quick syntax validation and exploring Oracle 23ai Vector Search / JSON duality syntax.
- **Official Link:** [https://livesql.oracle.com](https://livesql.oracle.com)

### Oracle Database 23ai Official Documentation `[Technical Docs]`
- **Description:** Comprehensive technical documentation covering SQL language reference, PL/SQL, security, and administration.
- **Project Role:** Definitive technical reference for all database features and syntax.
- **Official Link:** [https://docs.oracle.com/en/database/oracle/oracle-database/23/](https://docs.oracle.com/en/database/oracle/oracle-database/23/)

### Oracle APEX Documentation & Tutorials `[Technical Docs]`
- **Description:** Official documentation, API references, architecture guides, and enterprise application deployment tutorials.
- **Project Role:** Essential guide for APEX component design, authentication schemes, and JavaScript APIs.
- **Official Link:** [https://docs.oracle.com/en/database/oracle/apex/](https://docs.oracle.com/en/database/oracle/apex/)

<a id="community"></a>
## Community, Forums & Events

### Oracle APEX Community Forums `[Official Community]`
- **Description:** Official worldwide Oracle APEX community discussion platform, Q&A, product announcements, and expert troubleshooting.
- **Project Role:** Troubleshooting complex APEX issues, interactive grid tricks, and consulting Oracle product managers.
- **Official Link:** [https://forums.oracle.com/ords/r/apexds/community/home](https://forums.oracle.com/ords/r/apexds/community/home)

### Oracle Analytics & Publisher Community `[Official Community]`
- **Description:** Official community hub for Oracle Analytics Server, BI Publisher, Pixel Perfect reporting, and template design.
- **Project Role:** Sharing RTF templates, data model queries, and resolving Publisher formatting anomalies.
- **Official Link:** [https://community.oracle.com/products/oracleanalytics/](https://community.oracle.com/products/oracleanalytics/)

### Oracle SQL Developer for VS Code Community `[Official Forum]`
- **Description:** Official feedback and support forum for the Oracle SQL Developer extension in Visual Studio Code.
- **Project Role:** Reporting extension defects, submitting feature requests, and verifying DBTU connection behavior.
- **Official Link:** [https://forums.oracle.com/ords/apexds/domain/dev-community/category/sqldev-for-vscode](https://forums.oracle.com/ords/apexds/domain/dev-community/category/sqldev-for-vscode)

### Oracle APEX Global Events & Office Hours `[Events & Webinars]`
- **Description:** Live directory of upcoming APEX product office hours, developer meetups, technical webinars, and global user group conferences.
- **Project Role:** Staying informed about release roadmaps, APEX 26 new features, and live demonstrations.
- **Official Link:** [https://oracleapex.com/ords/r/apex_pm/apex-events/events](https://oracleapex.com/ords/r/apex_pm/apex-events/events)

### APEX Blogs Aggregator (CloudNueva) `[Community Aggregator]`
- **Description:** Comprehensive community aggregator indexing thousands of technical articles and tutorials authored by global Oracle APEX experts.
- **Project Role:** Discovering modern code snippets, CSS/JavaScript tricks, and real-world APEX solutions.
- **Official Link:** [https://apps.cloudnueva.com/ords/r/apps/apex_blogs/home](https://apps.cloudnueva.com/ords/r/apps/apex_blogs/home)

<a id="learning"></a>
## Hands-on Labs & Repositories

### Oracle LiveLabs Interactive Workshops `[Hands-on Labs]`
- **Description:** Free step-by-step guided hands-on workshops for Oracle Database 23ai, Vector Search, APEX, CI/CD, and Cloud Architecture.
- **Project Role:** Self-paced hands-on training on 23ai features directly applicable to platform development.
- **Official Link:** [https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/home)

### Oracle MyLearn Digital Learning `[Oracle University]`
- **Description:** Official Oracle University digital learning platform offering certified courses, role-based learning paths, and exams.
- **Project Role:** Professional certifications for Oracle Database Administrator (DBA) and APEX Developer.
- **Official Link:** [https://mylearn.oracle.com/ou/home](https://mylearn.oracle.com/ou/home)

### AskTOM Oracle Database Security Repository `[Security & Hardening]`
- **Description:** Curated scripts, demonstrations, and test suites maintained by Oracle's Database Security product management team.
- **Project Role:** Enterprise database hardening, Zero-Trust compliance, and security policy automation.
- **Official Link:** [https://github.com/oradbsec/AskTomDBSecurity](https://github.com/oradbsec/AskTomDBSecurity)
- **Download / CLI Command:**
  ```bash
  git clone https://github.com/oradbsec/AskTomDBSecurity.git
  ```

### Oracle AI Skills & Agentic Templates `[Agentic AI Skills]`
- **Description:** Open-source repository of Oracle digital assistant skills, agentic AI workflows, and conversational database integration tools.
- **Project Role:** Integrating intelligent natural language database queries with APEX applications.
- **Official Link:** [https://github.com/oracle/skills/](https://github.com/oracle/skills/)
- **Download / CLI Command:**
  ```bash
  git clone https://github.com/oracle/skills.git
  ```

### Oracle APEX Open Source Hub `[Open Source Hub]`
- **Description:** Curated showcase of official open-source plug-ins, developer extensions, UI templates, and starter projects by Oracle.
- **Project Role:** Adding certified interactive plug-ins, custom item types, and responsive dynamic actions to applications.
- **Official Link:** [https://oracle.github.io/apex/](https://oracle.github.io/apex/)

### Official Oracle Container Images Source Repository `[Official GitHub]`
- **Description:** Official repository with Dockerfiles and build scripts for Oracle commercial and open-source software (Database, WebLogic, Forms, FMW, Java, Linux).
- **Project Role:** Reference recipes and build scripts for building custom base containers and WebLogic domains.
- **Official Link:** [https://github.com/oracle/docker-images/tree/main](https://github.com/oracle/docker-images/tree/main)
- **Download / CLI Command:**
  ```bash
  git clone https://github.com/oracle/docker-images.git
  ```

