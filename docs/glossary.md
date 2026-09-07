# Architecture Glossary & Acronyms Reference

**[ 🇬🇧 English ]** | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/glossary.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/glossary.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/glossary.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/glossary.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/glossary.md)

> Comprehensive index of acronyms, technical definitions, and practical project roles.

---

**A–Z Register:** [A](#a) • [B](#b) • [C](#c) • [D](#d) • [E](#e) • [F](#f) • [G](#g) • [H](#h) • [I](#i) • [J](#j) • [K](#k) • [L](#l) • [M](#m) • [N](#n) • [O](#o) • [P](#p) • [R](#r) • [S](#s) • [T](#t) • [U](#u) • [V](#v) • [W](#w) • [Y](#y)

---

## A

### `ADB` — Autonomous Database
- **Definition:** Oracle's fully managed cloud database service that automates provisioning, patching, tuning, and scaling using AI/ML.
- **Role in this Project:** Target cloud environment for hybrid migrations (BP 10 & 11) via mTLS wallet connections without redesigning local code.
- **Official / External Reference:** [Oracle Autonomous Database](https://www.oracle.com/autonomous-database/)
- **Related Documentation & Scripts:** [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md), [scripts/deploy-remote.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-remote.sh)

### `APEX` — Oracle Application Express
- **Definition:** Oracle's low-code enterprise web application development platform running directly inside the database.
- **Role in this Project:** Central UI runtime hosted in Proxy DB (port 8448/8088), automated via APEXlang DSL and split SQLcl Git exports.
- **Official / External Reference:** [Wikipedia: Oracle APEX](https://en.wikipedia.org/wiki/Oracle_APEX)
- **Related Documentation & Scripts:** [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md), [scripts/internal/install-apex.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/install-apex.sh)

### `APFS` — Apple File System
- **Definition:** Default copy-on-write filesystem for macOS optimized for SSD storage, encryption, and snapshots.
- **Role in this Project:** Host filesystem on macOS developer machines where case-preserving portability (Rule 13) is verified against NTFS.
- **Official / External Reference:** [Wikipedia: Apple File System](https://en.wikipedia.org/wiki/Apple_File_System)
- **Related Documentation & Scripts:** [tests/unit/test-filename-portability.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-filename-portability.sh)

### `API` — Application Programming Interface
- **Definition:** A structured set of protocols and routines for building software and enabling systems to communicate.
- **Role in this Project:** Exposed locally via ORDS (AutoREST, OAuth2) and Dev Hub Bridge (/api/status, /api/podman, /api/tests) on port 8089.
- **Official / External Reference:** [Wikipedia: API](https://en.wikipedia.org/wiki/API)
- **Related Documentation & Scripts:** [docs/testing-framework-and-devhub.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/testing-framework-and-devhub.md), [scripts/internal/dev-hub-bridge.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/dev-hub-bridge.py)

## B

### `BIP` — Business Intelligence Publisher (Analytics Publisher)
- **Definition:** Enterprise document generation engine delivering pixel-perfect PDF, Excel, RTF, and XML reports at high volume.
- **Role in this Project:** Integrated in BP 4 & 11 (ports 9502/6083) for automated print templates and headless document generation.
- **Official / External Reference:** [Oracle Analytics Publisher Docs](https://docs.oracle.com/middleware/12213/bip/)
- **Related Documentation & Scripts:** [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md), [scripts/publisher/restart-publisher.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/publisher/restart-publisher.sh)

### `BP` — Blueprint (Architecture Blueprint)
- **Definition:** Pre-configured, idempotent architectural topologies declaring database containers, middleware, ports, and dev tools.
- **Role in this Project:** 12 canonical environments (BP 0 to BP 11) deployable via './scripts/deploy-blueprint.sh <ID>' or Dev Hub Cockpit.
- **Official / External Reference:** [Wikipedia: Blueprint](https://en.wikipedia.org/wiki/Blueprint)
- **Related Documentation & Scripts:** [config/blueprints/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/blueprints/README.md), [scripts/deploy-blueprint.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-blueprint.sh)

## C

### `CA` — Certificate Authority
- **Definition:** A trusted entity that issues cryptographic digital certificates for verifying identities and enabling TLS encryption.
- **Role in this Project:** Platform generates an autonomous local Root CA (certs/ca.crt) registered into OS trust stores (macOS, Windows, Linux).
- **Official / External Reference:** [Wikipedia: Certificate Authority](https://en.wikipedia.org/wiki/Certificate_authority)
- **Related Documentation & Scripts:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/certs/trust-local-cert-mac.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert-mac.sh)

### `CDB` — Container Database
- **Definition:** Oracle multitenant architecture root database that houses metadata and contains one or more pluggable databases (PDBs).
- **Role in this Project:** Standard CDB$ROOT in containerized 23ai Free DB; managed with zero manual configuration by init-db-instance.sh.
- **Official / External Reference:** [Oracle Multitenant Architecture](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html)
- **Related Documentation & Scripts:** [docs/db-profiles-and-topology.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/db-profiles-and-topology.md), [scripts/internal/init-db-instance.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sh)

### `CI/CD` — Continuous Integration / Continuous Deployment
- **Definition:** DevOps automated pipeline practice for building, testing, validating, and releasing code incrementally and safely.
- **Role in this Project:** Tested locally offline via './tests/test-local-ci.sh' and integrated into Dev Hub's Testing tab with 15 test suites.
- **Official / External Reference:** [Wikipedia: CI/CD](https://en.wikipedia.org/wiki/CI/CD)
- **Related Documentation & Scripts:** [tests/test-local-ci.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-local-ci.sh), [docs/devops-lifecycle-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/devops-lifecycle-guide.md)

### `CLI` — Command Line Interface
- **Definition:** Text-based user interface used to execute commands, automate scripts, and manage operating system resources.
- **Role in this Project:** Unified script layout in scripts/ (e.g. sqlcl.sh, get-password.sh, check-urls.sh) with dual terminal/GUI parity.
- **Official / External Reference:** [Wikipedia: Command-Line Interface](https://en.wikipedia.org/wiki/Command-line_interface)
- **Related Documentation & Scripts:** [scripts/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/README.md), [scripts/sqlcl.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/sqlcl.sh)

### `CPU` — Central Processing Unit
- **Definition:** The primary component of a computer that executes program instructions and processes operational data.
- **Role in this Project:** Monitored per-container in Dev Hub Cockpit; 23ai Free DB constrained to 2 vCPUs without throttled locks.
- **Official / External Reference:** [Wikipedia: CPU](https://en.wikipedia.org/wiki/Central_processing_unit)
- **Related Documentation & Scripts:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `CRLF` — Carriage Return Line Feed (\r\n)
- **Definition:** Two-byte newline delimiter standard in Windows DOS/NTFS filesystems, incompatible with Unix shells.
- **Role in this Project:** Strictly forbidden in shell scripts (.sh) by .gitattributes and verified in Rule 14 Windows dry-run tests.
- **Official / External Reference:** [Wikipedia: Newline (CRLF)](https://en.wikipedia.org/wiki/Newline)
- **Related Documentation & Scripts:** [.gitattributes](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/.gitattributes), [tests/unit/test-windows-enterprise-rules.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-windows-enterprise-rules.sh)

## D

### `DBA` — Database Administrator
- **Definition:** Professional responsible for database installation, security, tuning, backup recovery, and schema management.
- **Role in this Project:** Platform removes developer bottlenecks by automating 100% of DBA routines (wallet creation, users, grants, restarts).
- **Official / External Reference:** [Wikipedia: Database Administrator](https://en.wikipedia.org/wiki/Database_administrator)
- **Related Documentation & Scripts:** [scripts/internal/apply-profile-users.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/apply-profile-users.sh), [scripts/create-developer.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/create-developer.sh)

### `DR` — Disaster Recovery
- **Definition:** Processes and strategies that restore access to applications, data, and IT infrastructure following a catastrophe.
- **Role in this Project:** Achieved in ~15 seconds via Golden Snapshots (scripts/snapshots/), resetting corrupt environments with zero DBA tickets.
- **Official / External Reference:** [Wikipedia: Disaster Recovery](https://en.wikipedia.org/wiki/Disaster_recovery)
- **Related Documentation & Scripts:** [scripts/snapshots/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/README.md), [scripts/snapshots/restore-golden-snapshots.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/restore-golden-snapshots.sh)

### `DSL` — Domain-Specific Language
- **Definition:** A specialized programming or specification language tailored specifically to solve problems in a single domain.
- **Role in this Project:** APEXlang (.apx) declarative language for describing APEX pages, regions, items, and multi-language tokens.
- **Official / External Reference:** [Wikipedia: Domain-Specific Language](https://en.wikipedia.org/wiki/Domain-specific_language)
- **Related Documentation & Scripts:** [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md)

## E

### `E2E` — End-to-End Testing
- **Definition:** Testing methodology that validates entire software flows from user interface down to database persistence.
- **Role in this Project:** Represented by 6 suites in Dev Hub Testing tab (test-browser-login.sh, test-devhub-lifecycle-full.sh, etc.).
- **Official / External Reference:** [Wikipedia: End-to-End Testing](https://en.wikipedia.org/wiki/Software_testing#End-to-end_testing)
- **Related Documentation & Scripts:** [tests/test-browser-login.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-browser-login.sh), [docs/devhub-browser-testing-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/devhub-browser-testing-plan.md)

## F

### `FAT / NTFS` — File Allocation Table / New Technology File System
- **Definition:** Standard Windows filesystems with reserved characters (<, >, :, ", |, ?, *), trailing dot/space limits, and reserved device names.
- **Role in this Project:** Enforced by Rule 13 and unit tested across all repo files by tests/unit/test-filename-portability.sh.
- **Official / External Reference:** [Wikipedia: NTFS](https://en.wikipedia.org/wiki/NTFS)
- **Related Documentation & Scripts:** [tests/unit/test-filename-portability.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-filename-portability.sh)

### `FMW` — Fusion Middleware
- **Definition:** Oracle's enterprise software suite including WebLogic Server, Oracle Forms, Reports, and Analytics Publisher.
- **Role in this Project:** Containerized in BP 6 & 7 (Forms 14c) and BP 4 & 11 (Analytics Publisher) with automated fast health checks.
- **Official / External Reference:** [Wikipedia: Oracle Fusion Middleware](https://en.wikipedia.org/wiki/Oracle_Fusion_Middleware)
- **Related Documentation & Scripts:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md), [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md)

## G

### `GUI` — Graphical User Interface
- **Definition:** Visual display interface that allows users to interact with software through icons, buttons, and forms instead of CLI.
- **Role in this Project:** Provided by Dev Hub (dev-hub.html) on port 8448 with 1-click container actions, log streaming, and slide deck.
- **Official / External Reference:** [Wikipedia: GUI](https://en.wikipedia.org/wiki/Graphical_user_interface)
- **Related Documentation & Scripts:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html), [scripts/internal/generate_dev_hub.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/generate_dev_hub.py)

## H

### `HTTP / HTTPS` — Hypertext Transfer Protocol (Secure)
- **Definition:** The foundation protocol for data communication on the World Wide Web, secured by TLS encryption in HTTPS.
- **Role in this Project:** All platform web services (Dev Hub :8448, ORDS :8448/:8088, Publisher :9502, Forms :9001) run with zero browser warnings.
- **Official / External Reference:** [Wikipedia: HTTPS](https://en.wikipedia.org/wiki/HTTPS)
- **Related Documentation & Scripts:** [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

## I

### `i18n` — Internationalization
- **Definition:** Designing software to be adaptable to various languages and regions without engineering code changes.
- **Role in this Project:** Strictly mandated by Rule 9: 100% dictionary symmetry across 6 languages (EN, ET, FI, SV, LV, LT) in docs and Dev Hub.
- **Official / External Reference:** [Wikipedia: Internationalization (i18n)](https://en.wikipedia.org/wiki/Internationalization_and_localization)
- **Related Documentation & Scripts:** [tests/unit/test-i18n-translations.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/unit/test-i18n-translations.sh), [scripts/internal/i18n.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/i18n.sh)

### `IDE` — Integrated Development Environment
- **Definition:** Software suite consolidating developer tools (code editor, compiler/interpreter, debugger, version control) into one UI.
- **Role in this Project:** Supported locally via VS Code with Oracle extension and remotely via browser-based Web-IDE (BP 8, port 8090).
- **Official / External Reference:** [Wikipedia: IDE](https://en.wikipedia.org/wiki/Integrated_development_environment)
- **Related Documentation & Scripts:** [docker/web-ide/README.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docker/web-ide/README.md), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## J

### `JIT` — Just-In-Time (Decryption / Compilation)
- **Definition:** Execution or evaluation model where artifacts or credentials are processed dynamically in memory at the moment needed.
- **Role in this Project:** Core to Zero-Trust Rule 5: passwords decrypted dynamically via ./scripts/get-password.sh into RAM and destroyed on exit.
- **Official / External Reference:** [Wikipedia: Just-In-Time (JIT)](https://en.wikipedia.org/wiki/Just-in-time_compilation)
- **Related Documentation & Scripts:** [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md)

### `JSON` — JavaScript Object Notation
- **Definition:** Standard, lightweight, text-based data interchange format based on JavaScript object syntax.
- **Role in this Project:** Used for benchmark metrics (metrics/setup_benchmarks.json), Dev Hub REST APIs, and compiled HTML datasets.
- **Official / External Reference:** [Wikipedia: JSON](https://en.wikipedia.org/wiki/JSON)
- **Related Documentation & Scripts:** [metrics/setup_benchmarks.json](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/metrics/setup_benchmarks.json)

## K

### `KPI` — Key Performance Indicator
- **Definition:** Quantifiable measure used to evaluate the success of an organization, platform, or project in meeting objectives.
- **Role in this Project:** Displayed on Dev Hub presentation cards (e.g. -85% SEISAKUID, 1-KLIKK KÄIVITUS, ~15S TAASTE, 0€ LITSENTSIKULU).
- **Official / External Reference:** [Wikipedia: Key Performance Indicator](https://en.wikipedia.org/wiki/Performance_indicator)
- **Related Documentation & Scripts:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

## L

### `LF` — Line Feed (\n)
- **Definition:** Standard Unix/Linux single-byte newline character required by POSIX shell interpreters.
- **Role in this Project:** Mandated by Rule 14 across all .sh, .sql, .yaml, .json, and .md files via .gitattributes repository enforcement.
- **Official / External Reference:** [Wikipedia: Newline (LF)](https://en.wikipedia.org/wiki/Newline)
- **Related Documentation & Scripts:** [.gitattributes](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/.gitattributes)

### `LIS` — Laboratory Information System
- **Definition:** Enterprise software designed to manage healthcare laboratory sample workflows, instrument data, and test results.
- **Role in this Project:** Demonstrated in Blueprint 3 (Multi-DB with separate db-proxy, db-alise, and db-lis instances) showing schema isolation.
- **Official / External Reference:** [Wikipedia: LIS / LIMS](https://en.wikipedia.org/wiki/Laboratory_information_management_system)
- **Related Documentation & Scripts:** [config/blueprints/.env.bp3-multi-db-lis](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/blueprints/.env.bp3-multi-db-lis), [config/profiles/databases/db-lis.yaml](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/profiles/databases/db-lis.yaml)

## M

### `mTLS` — Mutual Transport Layer Security
- **Definition:** Two-way cryptographic authentication where both client and server verify each other's digital certificates.
- **Role in this Project:** Powers secure cloud bridging to OCI Autonomous Database (cwallet.sso) without opening unencrypted internet ports.
- **Official / External Reference:** [Wikipedia: Mutual TLS](https://en.wikipedia.org/wiki/Mutual_authentication#mTLS)
- **Related Documentation & Scripts:** [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

## N

### `noVNC` — HTML5 VNC Client (WebSocket)
- **Definition:** Browser-based VNC client written in HTML5 and JavaScript using WebSockets to access graphical desktops remotely.
- **Role in this Project:** Delivers zero-install Oracle Forms Builder (port 6082) and BIP Desktop Designer (port 6083) directly in Chrome/Edge.
- **Official / External Reference:** [Official: noVNC](https://novnc.com/)
- **Related Documentation & Scripts:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md), [docs/publisher-template-builder-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-template-builder-guide.md)

## O

### `OCI` — Oracle Cloud Infrastructure
- **Definition:** Oracle's broad enterprise public cloud platform offering computing, storage, networking, and managed databases.
- **Role in this Project:** Target cloud platform for automated deployments via scripts/deploy-remote.sh and hybrid blueprints (BP 10 & 11).
- **Official / External Reference:** [Wikipedia: Oracle Cloud Infrastructure](https://en.wikipedia.org/wiki/Oracle_Cloud)
- **Related Documentation & Scripts:** [scripts/deploy-remote.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/deploy-remote.sh), [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

### `OCR` — Oracle Container Registry
- **Definition:** Oracle's official container image registry (container-registry.oracle.com) hosting verified database and middleware images.
- **Role in this Project:** Source for official 23ai Free DB and ORDS images; supports enterprise Artifactory mirrors via REGISTRY_MIRROR config.
- **Official / External Reference:** [Official: Oracle Container Registry](https://container-registry.oracle.com/)
- **Related Documentation & Scripts:** [docs/enterprise-onboarding-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-onboarding-guide.md)

### `OPatch` — Oracle Interim Patching Tool
- **Definition:** Standard Oracle utility used to apply, rollback, and inspect official interim bug fixes and security patches.
- **Role in this Project:** Automated in scripts/internal/install-publisher.sh to patch Analytics Publisher without manual intervention.
- **Official / External Reference:** [Oracle Database Patching & Upgrade](https://docs.oracle.com/en/database/oracle/oracle-database/19/install-and-upgrade.html)
- **Related Documentation & Scripts:** [docs/publisher-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/publisher-setup.md)

### `ORDS` — Oracle REST Data Services
- **Definition:** Java EE application server bridge that turns SQL and PL/SQL into secure RESTful APIs and serves APEX applications.
- **Role in this Project:** Core API gateway on port 8088/8448; configured in standalone mode (BP 5 & 10) to eliminate database memory consumption.
- **Official / External Reference:** [Oracle REST Data Services](https://www.oracle.com/database/technologies/appdev/rest.html)
- **Related Documentation & Scripts:** [docs/ords-profiles-lifecycle.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ords-profiles-lifecycle.md), [scripts/internal/install-ords-standalone.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/install-ords-standalone.sh)

## P

### `PDB` — Pluggable Database
- **Definition:** A self-contained collection of schemas, schema objects, and non-schema objects that appears as a dedicated database.
- **Role in this Project:** Isolates application domains: FREEPDB1 (Proxy/APEX), ALISEPDB (Business Data), LIS_PDB, and BIP_PDB across blueprints.
- **Official / External Reference:** [Oracle Pluggable Database (PDB)](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/multitenant-architecture.html)
- **Related Documentation & Scripts:** [docs/db-profiles-and-topology.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/db-profiles-and-topology.md), [scripts/internal/resolve-topology.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/resolve-topology.sh)

### `PID` — Process Identifier
- **Definition:** A unique numeric identifier assigned by an operating system kernel to each running process.
- **Role in this Project:** Tracked by Dev Hub Bridge and task runners to ensure asynchronous background lifecycle control (Rule 12).
- **Official / External Reference:** [Wikipedia: Process Identifier (PID)](https://en.wikipedia.org/wiki/Process_identifier)
- **Related Documentation & Scripts:** [scripts/internal/dev-hub-bridge.py](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/dev-hub-bridge.py)

## R

### `RAM` — Random Access Memory
- **Definition:** High-speed volatile computer data storage used by active applications, operating system kernels, and buffers.
- **Role in this Project:** 23ai Free DB has a hard limit of 2GB RAM; platform's decoupled architecture prevents memory starvation.
- **Official / External Reference:** [Wikipedia: RAM](https://en.wikipedia.org/wiki/Random-access_memory)
- **Related Documentation & Scripts:** [docs/enterprise-distributed-architecture.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-distributed-architecture.md)

### `RCU` — Repository Creation Utility
- **Definition:** Oracle utility used to create, configure, and drop database schemas required by Fusion Middleware components.
- **Role in this Project:** Automated silently in headless containers for Forms 14c and Analytics Publisher initialization.
- **Official / External Reference:** [Oracle Repository Creation Utility Docs](https://docs.oracle.com/en/middleware/fusion-middleware/12.2.1.4/rcuug/)
- **Related Documentation & Scripts:** [docs/forms-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-setup.md)

### `REST` — Representational State Transfer
- **Definition:** Stateless, standard HTTP architectural design pattern for building decoupled, scalable web services and APIs.
- **Role in this Project:** Delivered natively via ORDS AutoREST, connecting APEX, external microservices, and Dev Hub without database drivers.
- **Official / External Reference:** [Wikipedia: REST](https://en.wikipedia.org/wiki/REST)
- **Related Documentation & Scripts:** [docs/ords-profiles-lifecycle.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ords-profiles-lifecycle.md)

### `ROI` — Return on Investment
- **Definition:** Financial performance metric measuring the profitability or efficiency gained relative to an investment cost.
- **Role in this Project:** Highlighted in Slide 5: saving up to 40% Oracle dev licensing costs and eliminating idle cloud cloud hosting fees.
- **Official / External Reference:** [Wikipedia: Return on Investment](https://en.wikipedia.org/wiki/Return_on_investment)
- **Related Documentation & Scripts:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

## S

### `SDW` — SQL Developer Web (Database Actions)
- **Definition:** Browser-based management interface provided by ORDS for executing SQL, data modeling, REST services, and monitoring.
- **Role in this Project:** Accessible via Dev Hub 1-click links for DBA_ADMIN, PROXY_DEV, and ALISE_DEV with auto-copied credentials.
- **Official / External Reference:** [Oracle SQL Developer Web](https://docs.oracle.com/en/database/oracle/sql-developer-web/)
- **Related Documentation & Scripts:** [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md)

### `SEPS` — Secure External Password Store (Oracle Wallet)
- **Definition:** Oracle's AES-256 encrypted auto-login wallet store (cwallet.sso) that enables passwordless client authentication.
- **Role in this Project:** Mandated by Rule 5: 0 plaintext passwords on disk; all CLI scripts (sqlcl.sh /@ALIAS) authenticate via SEPS wallet.
- **Official / External Reference:** [Oracle Database Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/)
- **Related Documentation & Scripts:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [scripts/check-wallet.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-wallet.sh)

### `SGA / PGA` — System Global Area / Program Global Area
- **Definition:** Oracle database memory architectures: SGA is shared across all processes, PGA is dedicated to individual server processes.
- **Role in this Project:** Dynamically tuned in init-db-instance.sql so combined memory strictly fits within the 2GB Free DB container boundary.
- **Official / External Reference:** [Wikipedia: Oracle Database Memory Architecture](https://en.wikipedia.org/wiki/Oracle_Database#Memory_structures)
- **Related Documentation & Scripts:** [scripts/internal/init-db-instance.sql](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sql)

### `SPA` — Single Page Application
- **Definition:** A web application that interacts with the user by dynamically rewriting the current web page rather than loading entire new pages.
- **Role in this Project:** Architecture of Dev Hub (docs/dev-hub.html): 100% standalone, zero CDN dependencies, instant tab navigation.
- **Official / External Reference:** [Wikipedia: Single-Page Application](https://en.wikipedia.org/wiki/Single-page_application)
- **Related Documentation & Scripts:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `SPFILE` — Server Parameter File
- **Definition:** Binary server parameter initialization file maintained on the database server across instance restarts.
- **Role in this Project:** Configured in container db-oracle to ensure optimal memory targets and APEX proxy authentication settings.
- **Official / External Reference:** [Wikipedia: Oracle Initialization Parameters](https://en.wikipedia.org/wiki/Oracle_Database#Initialization_parameters)
- **Related Documentation & Scripts:** [scripts/internal/init-db-instance.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sh)

### `SQL` — Structured Query Language
- **Definition:** Domain-specific standard language for managing data held in a relational database management system.
- **Role in this Project:** All platform schema setups, users, tablespaces, and grants executed via standard SQL files in scripts/internal/.
- **Official / External Reference:** [Wikipedia: SQL](https://en.wikipedia.org/wiki/SQL)
- **Related Documentation & Scripts:** [scripts/internal/init-db-instance.sql](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-db-instance.sql)

### `SQLcl` — Oracle SQL Developer Command Line
- **Definition:** Modern Java/GraalVM-based command-line interface for Oracle Database featuring inline editing, Liquibase, and Git integration.
- **Role in this Project:** Mandatory standard CLI per Rule 6 (legacy sqlplus strictly prohibited); auto-resolves VS Code extension binary.
- **Official / External Reference:** [Oracle SQLcl Official](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/)
- **Related Documentation & Scripts:** [scripts/sqlcl.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/sqlcl.sh), [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md)

### `SSO` — Single Sign-On
- **Definition:** Authentication scheme that allows a user to log in with a single ID to any of several related, yet independent software systems.
- **Role in this Project:** Integrated for enterprise deployments with Azure Entra-ID, ORDS, and APEX authentication schemes.
- **Official / External Reference:** [Wikipedia: Single Sign-On](https://en.wikipedia.org/wiki/Single_sign-on)
- **Related Documentation & Scripts:** [tests/test-browser-login.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tests/test-browser-login.sh)

## T

### `TCO` — Total Cost of Ownership
- **Definition:** Comprehensive assessment of information technology or other costs across social, hardware, software, and operational life.
- **Role in this Project:** Reduced dramatically by Oracle Free DB in Prod: 0€ license fees for development and internal tools.
- **Official / External Reference:** [Wikipedia: Total Cost of Ownership](https://en.wikipedia.org/wiki/Total_cost_of_ownership)
- **Related Documentation & Scripts:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `TLS` — Transport Layer Security
- **Definition:** Cryptographic protocol designed to provide end-to-end communications security over computer networks.
- **Role in this Project:** Generated locally via scripts/internal/generate-local-certs.sh for HTTPS on port 8448 and ORDS TLS termination.
- **Official / External Reference:** [Wikipedia: Transport Layer Security](https://en.wikipedia.org/wiki/Transport_Layer_Security)
- **Related Documentation & Scripts:** [docs/security.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/security.md), [scripts/internal/generate-local-certs.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/generate-local-certs.sh)

### `TNS` — Transparent Network Substrate
- **Definition:** Oracle's proprietary networking technology that enables peer-to-peer connectivity between clients and databases.
- **Role in this Project:** Auto-configured in tnsnames/tnsnames.ora with aliases like FREEPDB1, ALISEPDB, and automatically exported via TNS_ADMIN.
- **Official / External Reference:** [Wikipedia: Transparent Network Substrate](https://en.wikipedia.org/wiki/Transparent_Network_Substrate)
- **Related Documentation & Scripts:** [tnsnames/tnsnames.ora](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/tnsnames/tnsnames.ora), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## U

### `UAC` — User Account Control
- **Definition:** Windows security mechanism that prompts users for administrative permission before making system-wide changes.
- **Role in this Project:** Bypassed cleanly by Rule 14 (Zero-Admin): certificates registered to CurrentUser store, needing 0 elevation prompts.
- **Official / External Reference:** [Wikipedia: User Account Control](https://en.wikipedia.org/wiki/User_Account_Control)
- **Related Documentation & Scripts:** [scripts/certs/trust-local-cert.cmd](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert.cmd), [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md)

### `UI / UX` — User Interface / User Experience
- **Definition:** The visual appearance, controls, navigation, and holistic usability experience of a digital product or application.
- **Role in this Project:** Polished in Dev Hub: dark modern theme, 1-click clipboard helpers, interactive slides, and live container terminal UX.
- **Official / External Reference:** [Wikipedia: UI/UX Design](https://en.wikipedia.org/wiki/User_interface_design)
- **Related Documentation & Scripts:** [docs/dev-hub.html](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/dev-hub.html)

### `URI / URL` — Uniform Resource Identifier / Locator
- **Definition:** Standard address string used to identify and locate resources (web pages, APIs, documents) on a network.
- **Role in this Project:** Validated on platform startup by scripts/check-urls.sh ensuring all web services respond with HTTP 200/302.
- **Official / External Reference:** [Wikipedia: URI / URL](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)
- **Related Documentation & Scripts:** [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

## V

### `VPN` — Virtual Private Network
- **Definition:** Encrypted tunnel extending a private corporate network across a public network, protecting data traffic from interception.
- **Role in this Project:** Protected under Windows WSL2 via 'dnsTunneling=true' in .wslconfig, preventing corporate VPNs from dropping DNS.
- **Official / External Reference:** [Wikipedia: Virtual Private Network](https://en.wikipedia.org/wiki/Virtual_private_network)
- **Related Documentation & Scripts:** [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md)

### `VS Code` — Visual Studio Code
- **Definition:** Extensible, lightweight source-code editor developed by Microsoft with rich language and plugin support.
- **Role in this Project:** Primary IDE: auto-registers connections to Oracle SQL Developer extension via scripts/register-connections.sh.
- **Official / External Reference:** [Wikipedia: Visual Studio Code](https://en.wikipedia.org/wiki/Visual_Studio_Code)
- **Related Documentation & Scripts:** [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

## W

### `WSL / WSL2` — Windows Subsystem for Linux (Version 2)
- **Definition:** Native lightweight virtualized Linux utility inside Windows 10/11 running an authentic Linux kernel.
- **Role in this Project:** Mandated by Rule 14: workspace must live strictly inside native ext4 filesystem (~/ or /home/), never under /mnt/c/.
- **Official / External Reference:** [Wikipedia: Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux)
- **Related Documentation & Scripts:** [docs/windows-enterprise-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-enterprise-setup-guide.md), [setup.cmd](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/setup.cmd)

## Y

### `YAML` — YAML Ain't Markup Language
- **Definition:** Human-readable data serialization standard commonly used for configuration files and infrastructure declarations.
- **Role in this Project:** Mandated by Rule 11 as Single Source of Truth for database profiles (config/profiles/databases/*.yaml) and user grants.
- **Official / External Reference:** [Wikipedia: YAML](https://en.wikipedia.org/wiki/YAML)
- **Related Documentation & Scripts:** [config/profiles/databases/db-oracle.yaml](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/profiles/databases/db-oracle.yaml)

