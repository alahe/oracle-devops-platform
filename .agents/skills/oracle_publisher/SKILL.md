---
name: oracle_publisher_devops
description: Guidelines for Oracle Analytics Publisher (Pixel Perfect), REST API document generation, OPatch patching, and EmbeddedLDAP recovery.
---

# Oracle Analytics Publisher (Pixel Perfect): REST API & DevOps

This skill covers running **Oracle Analytics Publisher (Pixel Perfect / BI Publisher)**, generating documents via REST API, managing OPatch bundles, and resolving WebLogic startup crashes.

---

## 1. Architecture & Port Map

- **Publisher Web UI / REST API:** `http://localhost:9502/xmlpserver` (HTTPS: `9503`)
- **WebLogic AdminServer:** `http://localhost:9500` (HTTPS: `9501`)
- **Target Database (`db-publisher`):** Port `1531`/`1532`, PDB `FREEPDB1`, RCU prefix `OAS_*`.

---

## 2. Critical Failure Workarounds & Stability Rules

### 2.1 `EmbeddedLDAP` Hostname Crash Fix
* **Issue:** WebLogic embeds the ephemeral container ID hostname into `config/config.xml` `<listen-address>`. On container restart, `EmbeddedLDAP` fails to resolve the old hostname and triggers an assertion crash.
* **Fix:** Clear `<listen-address>` before booting WebLogic in `createAndStartDomain.sh`:
  ```bash
  sed -i 's|<listen-address>[^<]*</listen-address>|<listen-address></listen-address>|g' "${DOMAIN_HOME}/config/config.xml"
  ```
  And set static `hostname: publisher-dev` in `docker-compose.yml`.

### 2.2 `CONFIGURE_BIEE=false` Licensing Boundary
In Publisher-only environments, configure:
```bash
CONFIGURE_BIEE=false
CONFIGURE_BIP=true
```
This prunes configuration steps from 14 to 10 and skips importing the heavy `ee.bar` archive, preventing `UnexpectedBarImportException`.

### 2.3 ARM64 OpenSSL `keytool -gencert` CSR Signing
When generating certificates on ARM64/macOS, use Java `keytool -gencert` to sign CSRs (`openssl ca -infiles *.txt`), ensuring public/private key parity with Oracle Wallet.

---

## 3. Publisher REST API: Document Generation

Base URL: `http://localhost:9502/xmlpserver/services/rest/v1`

### 3.1 Synchronous PDF Generation (`POST /reports/{path}/run`)
```bash
PUBLISHER_PWD=$("./scripts/get-password.sh" "DB_PUBLISHER_SYS" | grep "Password:" | awk '{print $3}')

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

### 3.2 Asynchronous Batch Job (`POST /jobs`)
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

---

## 4. OPatch & Automation Scripts

```bash
# Apply OPatch zip bundle from patches/ directory:
./scripts/apply-publisher-patch.sh

# Check real-time service status (AdminServer, bi_server1, UI):
./scripts/internal/status-publisher.sh

# Backup report templates and catalog:
./scripts/internal/backup-publisher-catalog.sh
```
