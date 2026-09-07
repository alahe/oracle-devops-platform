# Jira Story: FIN-006 — ORDS Multi-Pool Configuration for Core Business DB

| Field | Value |
|:---|:---|
| **Story ID** | FIN-006 |
| **Epic** | Business Integration & Multi-Pool Routing |
| **Component** | ORDS / REST API / SEPS Wallet |
| **Priority** | High |
| **Estimation** | **5 Story Points** |
| **Target Environments** | DEV, TEST, PROD |
| **Dependencies** | FIN-004 |

---

## 1. User Story
**As an** Enterprise API Architect & Integration Engineer,  
**I want to** configure a secondary ORDS connection pool (`business`) on Server 1 that connects directly to the existing enterprise core business database using a SEPS Wallet mTLS alias,  
**So that** business data, REST services, and AutoREST endpoints from the core banking database can be accessed through ORDS without requiring complex database links or duplicating data into the Proxy DB.

---

## 2. Business Value & Financial Compliance
- **Data Freshness & Real-Time APIs:** REST consumers read and write directly to the authoritative business database with zero synchronization lag.
- **Security Isolation:** The `business` pool uses dedicated least-privilege credentials (`ORDS_PUBLIC_USER` restricted to business schemas) separate from the APEX administrator account.

---

## 3. Technical Scope & Architecture

### Files Created / Modified:
1. `/etc/ords/config/databases/business/pool.xml`: XML pool definition for the core business database.
2. `/etc/oracle/tns_admin/tnsnames.ora`: TNS definition for `BIZ_DB_REMOTE` (port 1521 / TCPS 2484).
3. `scripts/internal/configure-ords-multipool.sh`: Automated generator for secondary ORDS pools.

### Business Pool Configuration (`/etc/ords/config/databases/business/pool.xml`):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
  <comment>ORDS Connection Pool for Core Financial Business Database</comment>
  <entry key="db.connectionType">customurl</entry>
  <entry key="db.customURL">jdbc:oracle:thin:/@BIZ_DB_REMOTE</entry>
  <entry key="db.wallet.location">/etc/ords/wallet</entry>
  <entry key="db.tnsDirectory">/etc/ords/tns_admin</entry>
  <entry key="jdbc.MinLimit">5</entry>
  <entry key="jdbc.MaxLimit">100</entry>
  <entry key="jdbc.InitialLimit">10</entry>
  <entry key="jdbc.InactivityTimeout">1800</entry>
</properties>
```

---

## 4. Definition of Done (DoD)
- [ ] Pool XML file `/etc/ords/config/databases/business/pool.xml` deployed to Server 1.
- [ ] Wallet credentials for `BIZ_DB_REMOTE` verified via `sql /@BIZ_DB_REMOTE`.
- [ ] Requests to `https://ords-dev.corp.bank:8448/ords/business/` successfully route to the business DB.
- [ ] Existing `proxy` pool continues to serve APEX without interference (`/ords/r/proxy/*`).
- [ ] Connection pool failover / timeout tested under simulated network interruption.

---

## 5. Acceptance Criteria & Verification
```bash
# Query business database schema via ORDS REST API:
curl -k -s "https://ords-dev.corp.bank:8448/ords/business/open-api-catalog/services/" | jq .

# Expected Output:
# HTTP 200 OK with JSON array of published business REST services
```
