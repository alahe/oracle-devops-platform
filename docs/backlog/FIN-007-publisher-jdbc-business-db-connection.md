# Jira Story: FIN-007 — Analytics Publisher JDBC Connection to Business DB

| Field | Value |
|:---|:---|
| **Story ID** | FIN-007 |
| **Epic** | Business Integration & Reporting Data Sources |
| **Component** | Analytics Publisher / WebLogic JDBC / Data Sources |
| **Priority** | Medium |
| **Estimation** | **3 Story Points** |
| **Target Environments** | DEV, TEST, PROD |
| **Dependencies** | FIN-005 |

---

## 1. User Story
**As a** Financial BI & Pixel-Perfect Report Developer,  
**I want to** configure a secure JDBC data source in Analytics Publisher (Server 2) connecting to the existing core business database,  
**So that** business report data models can query financial tables directly with high throughput for PDF statement and report generation.

---

## 2. Business Value & Financial Compliance
- **Direct Reporting Without ETL:** Eliminates the need for intermediary staging tables or delayed data exports.
- **Audited Read-Only Service Account:** Connects with a restricted, read-only reporting role preventing accidental data modifications.

---

## 3. Technical Scope & Architecture

### Files Created / Modified:
1. `scripts/internal/configure-publisher-datasource.sh`: Automates creation of the JDBC data source via WebLogic Scripting Tool (WLST) or Publisher REST API.
2. WebLogic JDBC descriptor: `jdbc/CoreBusinessDS-jdbc.xml`.

### JDBC Connection String:
```text
jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=bizdb-dev.corp.bank)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=BIZDEV.CORP.BANK)))
```

---

## 4. Definition of Done (DoD)
- [ ] Data source `CoreBusinessDS` created in Analytics Publisher Administration console.
- [ ] Test Connection returns `Connection Test: Successful`.
- [ ] Sample data model query (`SELECT 1 AS STATUS FROM DUAL`) executes successfully.
- [ ] Credentials stored in WebLogic Credential Store (CSF) or SEPS Wallet; zero plaintext passwords.

---

## 5. Acceptance Criteria & Verification
```bash
# Execute automated data source connectivity test script:
./scripts/internal/configure-publisher-datasource.sh --test --ds CoreBusinessDS

# Expected Output:
# ✅ JDBC Data Source 'CoreBusinessDS' connection test: PASSED (latency: 12ms)
```
