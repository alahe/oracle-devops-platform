# 🧪 Automated & Manual Testing Framework

This directory contains automated test suites, manual testing guides, and historical execution reports for `oracle-free-db-in-prod`.

---

## 🔍 Testing Methodology & Architecture

The testing framework employs a 2-tier architecture balancing speed, safety, and functional accuracy:

### 1. Unit & Syntax Integrity Level (`bash -n` & Structure)
- Every shell script in `scripts/` and `scripts/internal/` has a dedicated 1-to-1 test script (`test-script-*.sh`).
- Performs static syntax analysis and structure checks using `bash -n` to catch missing loops, broken conditionals, or missing files before deployment.
- **Safety guarantee:** Fast execution without overwriting production wallets or mutating environment state.

### 2. Functional Assertion Level (Outcome & Assertions)
- **`test-script-create-wallet.sh`**: Validates that SEPS Wallet and TNS files (`cwallet.sso`, `ewallet.p12`, `tnsnames.ora`, `sqlnet.ora`) in `config/tns_admin/` exist, are non-empty, and structurally valid.
- **`test-password-generator.sh`**: Executes 50 iterations testing pure alphanumeric password compliance against Oracle Autonomous Database (ADB) regex (`^[a-zA-Z0-9]{20}$`).
- **`test-compose-override-generation.sh`**: Generates `podman-compose.override.yml` and verifies `IS_ADB="true"`, `WORKLOAD_TYPE=ATP`, and `ADMIN_PASSWORD` keys.
- **`test-script-create-developer.sh`**: Asserts mandatory inclusion of `DB_DEVELOPER_ROLE`.
- **`test-subcomponent-services.sh`**: Asserts SSL/TLS Root CA certificates, APEX images volume mounting, and ORDS HTTPS REST endpoint response codes.

---

## 📂 Directory Files & Test Guides

| File | Description |
| :--- | :--- |
| 🚀 **[test-all-components.sh](test-all-components.sh)** | **Master Automated Test Runner** executing all component test suites sequentially. |
| 🧪 **[test-db-profiles-and-topology.sh](test-db-profiles-and-topology.sh)** | Automated test runner for DB Profiles, Artifactory overrides, and Topology port collision resolver. |
| 🧪 **[test-instance-initializer.sh](test-instance-initializer.sh)** | Automated test runner for profile-driven DB instance initialization (`init-db-instance.sh`). |
| 🧪 **[test-profile-users-and-roles.sh](test-profile-users-and-roles.sh)** | Automated test runner for user provisioning, ORDS REST enabling, and APEX accounts (`apply-profile-users.sh`). |
| 🧪 **[test-password-generator.sh](test-password-generator.sh)** | Automated test runner for pure alphanumeric password generator (`generate-passwords.sh`). |
| 🧪 **[test-compose-override-generation.sh](test-compose-override-generation.sh)** | Automated test runner for Podman Compose Override generation and ADB environment variables (`IS_ADB`, `WORKLOAD_TYPE`, `ADMIN_PASSWORD`). |
| 🧪 **[test-subcomponent-services.sh](test-subcomponent-services.sh)** | Automated test runner for subcomponent services (SSL Root CA, Wallet credentials, APEX Images volume, ORDS HTTPS REST). |
| 🌐 **[test-browser-login.sh](test-browser-login.sh)** | **E2E Browser & UI Login Test Suite** validating ORDS, APEX Admin, and APEX Builder authentication + direct DB session timestamp verification (`APEX_WORKSPACE_ACTIVITY_LOG`). |
| 🚀 **[test-e2e-system.sh](test-e2e-system.sh)** | Full E2E System Integration Test Suite validating user scripts, internal scripts, profile matrix, and topology specifications. |
| 📘 **[profiles-and-topology-testing.md](profiles-and-topology-testing.md)** | Step-by-step testing guide for Database Profiles, Artifactory mirroring, and Topology resolution. |
| 📋 **[testing.md](testing.md)** | Complete functional and non-functional (NFR) testing methodology, including TDE encryption validation. |
| 📊 **[test-report.md](test-report.md)** | Historical E2E and HTTPS test execution report. |

---

## ⚡ Quickstart: Running Automated Tests

### Run All Automated Test Suites (Master Suite)
Runs all component test suites sequentially and outputs a unified green success report:

```bash
./tests/test-all-components.sh
```

### Run Individual Test Suites
```bash
./tests/test-db-profiles-and-topology.sh
./tests/test-instance-initializer.sh
./tests/test-profile-users-and-roles.sh
./tests/test-password-generator.sh
./tests/test-compose-override-generation.sh
./tests/test-subcomponent-services.sh
./tests/test-browser-login.sh
./tests/test-e2e-system.sh
```

---

## 🛠️ Summary of Key Test Scenarios

### F0: Dynamic Database Profiles & Topology
- **Profile Parsing:** Verifies parsing of `config/profiles/*.yaml` definitions.
- **Enterprise Artifactory Mirroring:** Verifies global registry prefixing via `ARTIFACTORY_DOCKER_REGISTRY=artifactory.company.local`.
- **Topology Port Allocator:** Verifies automatic port incrementation (`1532`, `1533`, `8443`, `8444`) when host ports are occupied.

### F1: Multi-Version APEX & ORDS Parallel Execution
- Verifies running APEX 24.1 (primary) and APEX 23.2 (secondary) in parallel without container port or static image conflicts.

### NFR1: Transparent Data Encryption (TDE) Validation
- Verifies tablespace encryption (`ENCRYPT_TABLESPACES=ALL`) and Oracle SEPS Wallet security.

### NFR2: Zero-Prompt SSL Certificate Trust
- Verifies automatic HTTPS certificate trust on macOS, Windows (`certutil -user -addstore Root`), and WSL.

---

## 🔮 Future Testing Roadmap
- **Item 7 ([docs/future-plans.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/future-plans.md#7-alamkomponentide--kogu-s%C3%BCsteemi-automaattestimise-raamistik)):** Full subcomponent & E2E system automated test suite (`tests/test-all-subcomponents.sh`).
