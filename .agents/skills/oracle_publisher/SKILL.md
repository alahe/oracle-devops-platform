---
name: oracle_publisher_devops
description: Guidelines for Oracle Analytics Publisher (Pixel Perfect), REST API document generation, OPatch patching, and EmbeddedLDAP recovery.
---

# Oracle Analytics Publisher (Pixel Perfect): REST API & DevOps

This skill covers running **Oracle Analytics Publisher (Pixel Perfect / BI Publisher)**, generating documents via REST API, managing OPatch bundles, and resolving WebLogic startup crashes.

---

## 1. When to Use & Negative Routing

### Positive Triggers (Activate this skill when:)
- Developing, generating, or automating reports via Oracle Analytics Publisher (BI Publisher / Pixel Perfect).
- Calling the Publisher REST API (`/xmlpserver/services/rest/v1`) to run reports or batch jobs synchronously or asynchronously.
- Deploying `.xdo` report templates or backing up the Publisher catalog (`scripts/publisher/*`).
- Troubleshooting WebLogic startup errors, such as `EmbeddedLDAP` hostname mismatch crashes.
- Applying Oracle OPatch maintenance patches to Analytics Publisher containers.
- Working with Blueprint 3 (Analytics Publisher), Blueprint 4 (Full Data Stack), Blueprint 7 (Mega Suite), or Blueprint 9 (Publisher Designer).

### Negative Routing (What NOT to do here:)
| Request / Intent | Do NOT handle here | Route to Skill |
|---|---|---|
| Developing Oracle Forms applications or noVNC builder | `oracle_forms_devops` | Use [oracle_forms_devops](file:///.agents/skills/oracle_forms_devops/SKILL.md) |
| APEX developer provisioning, pages, or SSO | `apex_dev` | Use [apex_dev](file:///.agents/skills/apex_dev/SKILL.md) |
| Database container lifecycle, memory, or faststart | `oracle_containers` | Use [oracle_containers](file:///.agents/skills/oracle_containers/SKILL.md) |
| Extracting or rotating SEPS wallet credentials | `wallet_security_rotation` | Use [wallet_security_rotation](file:///.agents/skills/wallet_security_rotation/SKILL.md) |
| Authoring or validating Mermaid architecture diagrams | `mermaid_diagram_design` | Use [mermaid_diagram_design](file:///.agents/skills/mermaid_diagram_design/SKILL.md) |

---

## 2. Architecture & Port Map

| Component | Port / URL | Description |
|---|---|---|
| **Publisher Web UI / REST** | `http://localhost:9502/xmlpserver` | Web console and REST API endpoint (HTTPS: `9503`) |
| **WebLogic AdminServer** | `http://localhost:9500` | WLS AdminServer console (HTTPS: `9501`) |
| **Publisher Managed Server**| `http://localhost:9502` | `bi_server1` managed server hosting BIP |
| **Target Database Backend** | Port `1531`/`1532`, PDB `FREEPDB1` | Dedicated Oracle 23ai instance (`db-publisher`) |

- **Profiles & Blueprints:** Profile `config/profiles/publisher/publisher-standard.yaml`, used by Blueprint 3, 4, 7, and 9.
- **Repository Schema (RCU):** Prefix `OAS_*` (`OAS_STB`, `OAS_OPSS`, `OAS_WLS`, `OAS_BIPLATFORM`) created in `FREEPDB1`.

---

## 3. Operational Playbooks & Step-by-Step Execution

### 3.1 Real-Time Status & Diagnostics (`status-publisher.sh`)
Check whether AdminServer, `bi_server1`, and web services are responding:
```bash
./scripts/publisher/status-publisher.sh
```

### 3.2 Synchronous Document Generation via REST API (`POST /reports/{path}/run`)
Generate a PDF or Excel document directly from an `.xdo` report definition using SEPS wallet credentials:
```bash
# Extract WebLogic administrator password from SEPS Wallet:
PUBLISHER_PWD=$("./scripts/get-password.sh" "DB_PUBLISHER_SYS" | grep "Password:" | awk '{print $3}')

# Request PDF report:
curl -s -u weblogic:"${PUBLISHER_PWD}" \
  -H "Content-Type: application/json" \
  -X POST "http://localhost:9502/xmlpserver/services/rest/v1/reports/Guest%2FInvoices%2FInvoice_Report.xdo/run" \
  -d '{
    "attributeFormat": "pdf",
    "attributeLocale": "en-US",
    "parameterNameValues": {
      "listOfParamNameValues": [
        {"name": "P_INVOICE_ID", "values": ["10045"]}
      ]
    }
  }' \
  --output invoice_10045.pdf
```

### 3.3 Asynchronous Batch Reporting Job (`POST /jobs`)
Submit heavy report jobs to run in the background:
```bash
curl -s -u weblogic:"${PUBLISHER_PWD}" \
  -H "Content-Type: application/json" \
  -X POST "http://localhost:9502/xmlpserver/services/rest/v1/jobs" \
  -d '{
    "jobName": "Monthly_Billing_Job",
    "reportPath": "/Guest/Reports/Billing_Monthly.xdo",
    "saveDataOption": true
  }'
```

### 3.4 Enterprise Report Scaffolding & GitOps Deployment (`applications/publisher/`)
Reports and data models reside in `applications/publisher/Custom/<Domain>/<ReportName>/`:
- **Create new report package:**
  ```bash
  ./scripts/publisher/create-report.sh Custom/Invoices/Packing_Slip "Packing Slip"
  ```
- **Deploy via REST API (Idempotent JIT Packaging):**
  ```bash
  ./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --mode rest
  ```
- **Deploy with instant test-render verification:**
  ```bash
  ./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --render
  ```

### 3.5 Backing Up the Publisher Catalog (`backup-publisher-catalog.sh`)
Export all customized templates, data models, and report definitions to a versioned archive:
```bash
./scripts/publisher/backup-publisher-catalog.sh
```

### 3.6 Two-Phase Security & Credential Rotation
- **Phase 1 (Active by Default - SEPS Wallet):**
  - Developer: `bip_developer` / `PUBLISHER_DEVELOPER` (XMLP_DEVELOPER, XMLP_TEMPLATE_DESIGNER)
  - Business User / API: `bip_user` / `PUBLISHER_USER` (XMLP_SCHEDULER, XMLP_ANALYZER)
  - Catalog Admin: `bip_admin` / `PUBLISHER_ADMIN` (XMLP_ADMIN)
- **Rotate Passwords:**
  ```bash
  ./scripts/rotate-password.sh publisher dev     # bip_developer
  ./scripts/rotate-password.sh publisher user    # bip_user
  ./scripts/rotate-password.sh publisher admin   # bip_admin
  ```
- **Phase 2 (Standby):** Azure Entra-ID SAML 2.0 Web SSO & OAuth2 M2M Bearer tokens configured via `scripts/internal/configure-publisher-sso.sh`.

### 3.7 CI/CD Pipeline (`.github/workflows/deploy-publisher-reports.yml`)
Automated quality gates (xmllint, SQL validation, PDF/UA-1 accessibility audit, test-render, artifact upload) with `workflow_dispatch` deployment to target environments.

### 3.8 Applying Maintenance Patches (`apply-publisher-patch.sh`)
Apply official Oracle OPatch zip files from the `patches/` directory:
```bash
./scripts/apply-publisher-patch.sh patches/p36000000_122140_Generic.zip
```

### 3.9 Resolving `EmbeddedLDAP` Hostname Crash
When an ephemeral container ID changes on restart, WebLogic's `EmbeddedLDAP` may fail:
```bash
# Clear stale <listen-address> before booting WebLogic in createAndStartDomain.sh:
sed -i 's|<listen-address>[^<]*</listen-address>|<listen-address></listen-address>|g' "${DOMAIN_HOME}/config/config.xml"

# Ensure static hostname is set in docker-compose.yml:
# hostname: publisher-dev
```

---

## 4. Mandatory Rules & Strict Prohibitions (Anti-Patterns)

- ❌ **Prohibit `CONFIGURE_BIEE=true` in Publisher-Only Setups:** Always enforce `CONFIGURE_BIEE=false` and `CONFIGURE_BIP=true`. This avoids importing `ee.bar` and prevents `UnexpectedBarImportException`.
- ❌ **Prohibit Host-Side Archive Unpacking:** Large Publisher archives (50,000+ files) must never be unpacked directly onto the host filesystem; unpack strictly inside the container per Rule 4.
- ❌ **Prohibit Plaintext Passwords on Disk:** Never hardcode WebLogic credentials in curl scripts or config files; query them just-in-time via `./scripts/get-password.sh` per Rule 5.
- ❌ **Prohibit Skipping RCU Schema Verification:** Never attempt to start `bi_server1` before verifying that the repository schemas (`OAS_*`) in `FREEPDB1` are valid.

---

## 5. Diagnostic Signatures & 1-Line Remedies (Troubleshooting)

| Error Code / Symptom | Root Cause | 1-Line Remediation |
|---|---|---|
| `EmbeddedLDAP assertion crash / Hostname mismatch` | WebLogic pinned ephemeral container hostname in `config.xml` | Clear `<listen-address>` in `config.xml` and ensure static `hostname: publisher-dev`. |
| `UnexpectedBarImportException: Failed to import ee.bar` | `CONFIGURE_BIEE=true` attempted to configure full BI Enterprise Edition | Set `CONFIGURE_BIEE=false` and `CONFIGURE_BIP=true` in configuration environment. |
| `HTTP 401 Unauthorized` on REST API call | Wrong credentials or user locked out | Query genuine WebLogic password via `./scripts/get-password.sh DB_PUBLISHER_SYS`. |
| `OPatch failed with error code 73` | Prerequisite patch conflict or active running WebLogic process | Stop WebLogic managed servers before applying OPatch bundle. |
| `java.lang.OutOfMemoryError: Metaspace` | Insufficient JVM Metaspace allocated for BI Publisher classes | Increase `-XX:MaxMetaspaceSize=1024m` in WebLogic startup arguments. |
| `Connection refused on port 9502` | `bi_server1` is still initializing or boot stalled | Run `./scripts/publisher/status-publisher.sh` and inspect WebLogic boot log. |
