[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# Passive Core Database & DMZ Proxy Architecture (Transactional Outbox Pattern)

This architectural pattern enforces strict enterprise security boundaries for financial core databases.

---

## 1. Security Principle: Core DB is NOT an Outbound Actor

In high-security banking and financial platforms:
- **Core Business DB (`db-alise`):** Strictly isolated inside the private network zone. It is prohibited by network firewall policies and corporate governance from initiating outbound TCP, HTTP, or message broker (Kafka/RabbitMQ) connections.
- **DMZ / Middleware Proxy DB (`db-proxy` / ORDS):** Located in the intermediate service tier. Permitted to communicate outbound to external partner APIs, enterprise Kafka clusters, and downstream cloud services.

```
┌────────────────────────────────────────────────────────┐
│ DMZ / MIDDLEWARE ZONE (ACTIVE OUTBOUND ACTOR)          │
│                                                        │
│  ┌────────────────────────┐    ┌────────────────────┐  │
│  │     ORDS (Gateway)     │    │  Proxy DB (:1532)  │  │
│  │  • Inbound REST APIs   │    │  • DBMS_SCHEDULER  │  │
│  │  • Web Application     │    │  • Outbox Poller   │  │
│  └───────────┬────────────┘    └─────────┬──────────┘  │
└──────────────┼───────────────────────────┼─────────────┘
               │ (Inbound calls only)      │ (PULL: queries pending events)
               ▼                           ▼
┌────────────────────────────────────────────────────────┐
│ PRIVATE CORE ZONE (PASSIVE DATASTORE)                  │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Core Business DB (:1533)                         │  │
│  │ • Financial transactions & ledger                │  │
│  │ • Local OUTBOX_EVENTS table (Transaction-safe)   │  │
│  │ • 0 outbound TCP sockets or external HTTP calls  │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
               ▲
               │ (Result of external dispatch written back by Proxy)
```

---

## 2. Execution Flow (Transactional Outbox)

1. **Transaction Phase (Core DB):**
   - A business procedure executes a balance transfer or batch calculation.
   - In the **same database transaction** (`COMMIT`), it writes to `outbox_events` via `pkg_outbox.publish_event(...)`.
   - If the transaction rolls back, no outbox event is persisted. Zero "ghost messages".
2. **Polling & Dispatch Phase (Proxy DB):**
   - `JOB_PROXY_OUTBOX_DISPATCHER` in `db-proxy` queries `CORE_DB.outbox_events` where `status = 'PENDING'`.
   - The Proxy DB initiates the outbound HTTP request (`APEX_WEB_SERVICE`) or Kafka event.
3. **Acknowledgment Phase:**
   - Upon receiving HTTP `200 OK` or Kafka broker ACK, the Proxy DB updates `outbox_events.status = 'PUBLISHED'` in Core DB.
   - In case of network errors, status is updated to `'FAILED'` with exponential retry backoff.

---

## 3. Deployment & Local Verification

In this platform:
- Blueprint 0 (`config/blueprints/.env.0-default-proxy-ords`) provides `db-proxy` and `app-ords`.
- Blueprint 1 (`config/blueprints/.env.1-standalone-alise-db`) provides the isolated core business database `db-alise`.
- Both containers run concurrently on isolated ports (`1532` and `1533`), accurately emulating production DMZ vs Core network segregation.
