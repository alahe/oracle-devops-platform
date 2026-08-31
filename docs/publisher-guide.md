# Oracle Analytics Publisher (Pixel Perfect) Integration Guide

This guide describes how to configure, build, run, patch, and manage **Oracle Analytics Publisher (Pixel Perfect / BI Publisher)** locally with Podman or on Linux servers natively without Podman.

---

## 1. Quick Architecture & Execution Modes

Oracle Analytics Publisher supports two execution engines:
1. **Container Mode (Podman / Docker)**: For local development and containerized production environments (`oracle-publisher-dev`, ports `9502:9502` / `9503:9503`).
2. **Native Linux Server Mode (Non-Containerized VM)**: Silent response-file installer (`./scripts/install-publisher.sh`) for enterprise RHEL/Oracle Linux VMs.

---

## 2. Profile Configuration

Publisher profiles are defined in `config/profiles/databases/publisher-free.yaml` and `config/profiles/databases/appinfra.yaml`:

```yaml
profile:
  id: publisher-free
  name: publisher-free
  description: "Dedicated Oracle Database & Analytics Publisher with RCU schemas and ORDS REST management."

components:
  ords:
    enabled: true
    container_name: oracle-ords-publisher
    http_port: 8089
    https_port: 8449
  publisher:
    enabled: true
    container_name: oracle-publisher-dev
    http_port: 9502
    https_port: 9503
    rcu_prefix: OAS
    domain_name: bi
```

---

## 3.1 Automated JDBC Data Source & PUBLISHER_READER Wallet Setup

Analytics Publisher connects automatically to the business application database (`db-alise` or remote DB) using a dedicated, least-privileged system account **`PUBLISHER_READER`**:

1. **Oracle SEPS Wallet (`cwallet.sso`) Integration**:
   - The password for `PUBLISHER_READER` is generated and stored securely in Oracle SEPS Wallet under alias `DB_PUBLISHER_READER`.
   - Developers and CLI tools connect passwordlessly via SQLcl:
     ```bash
     sql /@DB_PUBLISHER_READER
     ```
   - Connection folder in VS Code SQL Developer extension: `/Publisher/DB_PUBLISHER_READER`.

2. **Automated JDBC Data Source Registration (`ALISE_APP_DB`)**:
   - During setup (`./scripts/setup-all.sh`), script `scripts/internal/init-publisher-datasource.sh` generates the JDBC Data Source XML configuration `ALISE_APP_DB.xml` inside Publisher repository.
   - Works seamlessly for both **Local Container DBs (`db-alise:1521/FREEPDB1`)** and **Remote Enterprise DBs (`$DB_HOST:$DB_PORT/$DB_SERVICE`)**.

---

## 3. Automated Binary Downloads & Image Building

The build system includes an automated binary downloader (`./scripts/internal/download-publisher-binary.sh`) that fetches `V1055080-01.zip` / `V1045135-01.zip` automatically before building:

1. **Option 1: Corporate Artifactory / Mirror (Recommended for Enterprises)**  
   Set the binary download URL in `.env`:
   ```bash
   PUBLISHER_BINARY_URL=https://artifactory.internal.repo/oracle/publisher/V1055080-01.zip
   ```
2. **Option 2: Oracle eDelivery Download Token**  
   Set your session download token in `.env`:
   ```bash
   PUBLISHER_DOWNLOAD_TOKEN=U2NVaDRzTVJITUF5bWky...
   ```
3. **Option 3: Manual Placement**  
   Place `V1055080-01.zip` or `Oracle_Analytics_Server_2026_Linux*.zip` directly in `binaries/publisher/`.

Build the container image using the imported Oracle build templates:

```bash
./docker/publisher/build-publisher-image.sh 2025
```

---

## 4. Web UI URLs, Credentials & RCU Integration

### 🌐 Access URLs & Credentials
- **Publisher UI (Browser)**: `http://localhost:9502/xmlpserver`
- **WebLogic Console**: `http://localhost:9500/console`
- **Default Admin User**: `weblogic`
- **Password Retrieval from Oracle Wallet**:
  ```bash
  ./scripts/get-password.sh DB_PUBLISHER_SYS
  ```

### 🗄️ Database Architecture & Roles
1. **`db-publisher` (Port 1531 / SID: FREE / PDB: FREEPDB1)**: Dedicated Metadata Database storing WebLogic RCU schemas (`OAS_STB`, `OAS_CONFIG`, `OAS_BIPLATFORM`, `OAS_MDS`). Connect via `sql /@DB_PUBLISHER_SYS as sysdba`.
2. **`db-apex-proxy` (Port 1532 / SID: FREE / PDB: FREEPDB1)**: Client Application, APEX Proxy, and ORDS REST API database. Connect via `sql /@DB_APEX_PROXY_SCHEMA` or `sql /@DB_APEX_PROXY_SYS as sysdba`.

---

## 5. Automated Patching

Place Oracle OPatch ZIP files (e.g., `p39179920_publisher.zip`) into the `patches/` directory and execute:

```bash
./scripts/apply-publisher-patch.sh
```

Execution output is logged to `install_logs/publisher_patch_YYYYMMDD_HHMMSS.log` and duration metrics are recorded in `metrics/setup_benchmarks.json`.

---

## 6. Useful Resources & Video Tutorials

- ⬇️ **Required Software Downloads (Oracle eDelivery):**
  - ☕ **Java JDK Download:** [Oracle Java Downloads](https://www.oracle.com/java/technologies/downloads/)
  - 🏢 **Fusion Middleware / WebLogic Server Download:** [Oracle WebLogic Server & FMW Installers](https://www.oracle.com/middleware/technologies/weblogic-server-installers-downloads.html)
  - 📊 **Analytics Publisher Download:** [Oracle Software Delivery Cloud (eDelivery)](https://edelivery.oracle.com/osdc/faces/SoftwareDelivery)

### 📦 Oracle eDelivery Package Reference & Checksums

### 🔑 Enterprise Licensing & Compliance (Oracle eDelivery Licenses)

Downloading and using Oracle Analytics Publisher software requires one of the following official Oracle enterprise licenses:
- Oracle Analytics Publisher for Oracle Applications or OBI Publisher for Oracle Applications
- **Oracle Analytics Publisher or Oracle Business Intelligence Publisher** *(Active Enterprise License)*
- Oracle Analytics Server Administrator or Oracle Business Intelligence Server Administrator
- Oracle Analytics Server for Oracle Applications or OBI Suite Extended Edition for Oracle Applications
- Oracle Analytics Server or Oracle Business Intelligence Suite Extended Edition
- Oracle Analytics Standard Edition One or Oracle Business Intelligence Standard Edition One

> [!NOTE]
> Active Corporate License: **Oracle Business Intelligence Publisher**.

---

## 6. Useful Resources & Video Tutorials
- 📕 **Official Complete PDF User Guide:** [Using Oracle Analytics Publisher in Oracle Analytics Server (PDF)](https://docs.oracle.com/en/middleware/bi/analytics-server/user-publisher-oas/using-oracle-analytics-publisher-oracle-analytics-server.pdf)
- 🏗️ **Oracle Fusion Middleware 14.1.2 Infrastructure Readme:** [Oracle Fusion Middleware 14.1.2 Download, Installation, and Configuration Readme](https://docs.oracle.com/en/middleware/fusion-middleware/14.1.2/mstrd/download-installation-and-configuration-readme.html)
- 📦 **Official Software Installation Chapter:** [Installing the Oracle Analytics Server Software](https://docs.oracle.com/en/middleware/bi/analytics-server/install-config-oas/installing-product-software.html#GUID-D5AFD830-8A7D-42CC-8C22-CE68C452CF4A)
- ⚙️ **Official Silent Installation Guide:** [Installing Oracle Analytics Server Software in Silent Mode](https://docs.oracle.com/en/middleware/bi/analytics-server/install-config-oas/oracle-analytics-server-installation.html#GUID-FA987D32-0E3B-40AF-AB81-2196F823C667)
- 📖 **Official REST API Endpoints:** [Oracle Analytics Server REST API Documentation](https://docs.oracle.com/en/middleware/bi/analytics-server/oap_rest_api/rest-endpoints.html)
- 📘 **Official Report Design Guide:** [Create Pixel-Perfect Reports in Oracle Analytics Server](https://docs.oracle.com/en/middleware/bi/analytics-server/create-pixel-perfect-reports.html)
- 📜 **Official Introduction to Pixel-Perfect Publishing:** [Introduction to Pixel-Perfect Publishing](https://docs.oracle.com/en/middleware/bi/analytics-server/user-publisher-oas/introduction-pixel-perfect-publishing.html)
- 💻 **Desktop Tools Download Guide (Word/Excel Template Builders):** [Download Desktop Tools for Publisher](https://docs.oracle.com/en/middleware/bi/analytics-server/user-publisher-oas/download-desktop-tools.html)
- 📄 **Custom Skill Instructions:** [.agents/skills/oracle_publisher/SKILL.md](../.agents/skills/oracle_publisher/SKILL.md)
