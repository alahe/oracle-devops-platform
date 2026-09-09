---
name: oracle_containers_devops
description: Guidelines for running official Oracle 23ai Free DB containers, managing resource limits, Vector Search, FastStart images, and in-container unzipping.
---

# Oracle Containers for DevOps: Oracle 23ai Free DB & Tooling

This skill provides guidelines for running official Oracle database containers (23ai Free DB, SQLcl, ORDS) for local development, CI/CD pipelines, and multi-architecture hosts.

---

## 1. 🎯 When to Use & Negative Routing

### Positive Triggers (Activate Immediately):
- Running or tuning Oracle Database Free (23ai) containers (`container-registry.oracle.com/database/free:latest`)
- Managing container memory, process limits (`ALTER SYSTEM SET processes=300`), or PDB open state
- AI Vector Search (`VECTOR(512, FLOAT32)`), Cosine distance queries, or JSON Relational Duality Views
- In-container unzipping (`podman cp` + unpack in `/tmp`) to bypass Windows/Mac antivirus I/O bottlenecks
- Direct multitenant PDB connection and serial recompilation (`recomp_serial`)

### Negative Routing (Redirect to Specialized Skills):
| If the task is primarily about... | DO NOT handle here. Route immediately to: |
|:---|:---|
| Multi-blueprint topology or port numbers (1531-1534) | `blueprints_and_topology` |
| Full lifecycle setup (`setup-all.sh`, `reset-all.sh`) | `setup_orchestration` |
| SEPS Wallet credentials or passwordless connect | `wallet_security_rotation` |
| Instant ~15s snapshot backup & restore | `golden_snapshots_dr` |
| Forms 14c container and noVNC builder | `oracle_forms_devops` |
| Analytics Publisher container and OPatch | `oracle_publisher` |

---

## 2. Oracle 23ai Free DB Resource Limits & Invariants

Oracle Database Free (23ai) operates under strict built-in limits:
- **User Data Storage:** Max 12 GB.
- **CPU Cores:** Max 2 CPU cores.
- **Database RAM (SGA+PGA):** Max 2 GB RAM.

### 1.1 Process & Session Limit Optimization
When running multi-service topologies (Web IDE + ORDS + Forms + SQLcl), concurrent connections can trigger `ORA-00018: maximum number of sessions exceeded` or `ORA-00020: maximum number of processes exceeded`.

Increase the process ceiling:
```sql
ALTER SYSTEM SET processes=300 SCOPE=SPFILE;
```

### 1.2 PDB Open State Persistence
Ensure the pluggable database automatically opens on container restart:
```sql
ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE;
```

---

## 2. Oracle 23ai Features: Vector Search & JSON Duality Views

### 2.1 AI Vector Search (`VECTOR` Data Type)
```sql
CREATE TABLE document_embeddings (
    doc_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title      VARCHAR2(255),
    content    CLOB,
    embedding  VECTOR(512, FLOAT32)
);

-- Cosine Similarity Query:
SELECT title, VECTOR_DISTANCE(embedding, :user_query_vec, COSINE) AS distance
FROM document_embeddings
ORDER BY distance
FETCH FIRST 5 ROWS ONLY;
```

### 2.2 JSON Relational Duality Views
```sql
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW customer_dv AS
SELECT JSON {'customerId': c.id, 'name': c.name, 'email': c.email}
FROM customers c WITH INSERT UPDATE DELETE;
```

---

## 3. Performance & Antivirus Optimization (In-Container Unzip)

> [!IMPORTANT]
> **Host Unpack Prohibition:**
> Unpacking large software archives (APEX 26.1, ORDS, Publisher containing 50,000+ files) on enterprise host disks triggers real-time Microsoft Defender / Antivirus file scanning, causing severe I/O degradation.

**Rule:**
1. Keep archives as single compressed files in `binaries/` on the host.
2. Transfer archives via `podman cp ... $CONTAINER:/tmp/`.
3. Unpack and compile exclusively inside the container filesystem (`/tmp/apex_install/`).

---

## 5. Multitenant PDB Context & Clock Skew Resilience (Multi-DB Invariants)

### 5.1 Multitenant PDB Direct Connection Rule (`CDB$ROOT` Drop Prevention)
When executing complex administrative scripts (APEX engine install, ORDS metadata setup, patching) targeted at a Pluggable Database (`FREEPDB1`), **never rely on `sql / as sysdba` followed by `ALTER SESSION SET CONTAINER`**. Internal `CONNECT` commands inside Oracle vendor scripts drop back to `CDB$ROOT`.
- **Mandatory Pattern:** Always connect directly using the explicit PDB service via SQLcl (Rule 6):
  ```bash
  sql -s "sys/${SYS_PASSWORD}@localhost:${DB_PORT}/${DB_SERVICE} as sysdba" @script.sql
  # Or inside container:
  /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql -s "sys/${SYS_PASSWORD}@localhost:1521/${DB_SERVICE} as sysdba" @script.sql
  ```

### 5.3 Tablespace Pre-allocation Invariant (Preventing I/O Lock Freezes & ORA-03114)
Oracle Free DB initializes datafiles with small sizes (e.g. `SYSAUX` at 480MB, 10MB auto-extend). Heavy installations (APEX, ORDS metadata) perform hundreds of sequential datafile resize operations, creating severe I/O lock contention, private strand flush freezes (`Thread 1 cannot allocate new log`), and client disconnects (`ORA-03114`).
- **Rule:** Always pre-allocate datafiles with larger chunks prior to heavy workloads:
  ```sql
  ALTER DATABASE DATAFILE '/opt/oracle/oradata/FREE/FREEPDB1/sysaux01.dbf' RESIZE 2048M AUTOEXTEND ON NEXT 128M MAXSIZE UNLIMITED;
  ALTER DATABASE DATAFILE '/opt/oracle/oradata/FREE/FREEPDB1/system01.dbf' RESIZE 1024M AUTOEXTEND ON NEXT 128M MAXSIZE UNLIMITED;
  ALTER DATABASE DATAFILE '/opt/oracle/oradata/FREE/FREEPDB1/undotbs01.dbf' RESIZE 512M AUTOEXTEND ON NEXT 64M MAXSIZE UNLIMITED;
  ```

### 5.4 Serial vs Parallel Recompilation in PDBs (Preventing ORA-609 Scheduler Slave Timeouts)
In containerized PDB environments, `sys.utl_recomp.recomp_parallel` spawns `DBMS_SCHEDULER` worker jobs originating from `CDB$ROOT`. Under heavy CPU/IO load, these worker jobs encounter TCP listener authentication timeouts (`ORA-609: could not attach to incoming connection`), terminating the parent session.
- **Rule:** In containerized PDB installations, replace parallel recompilation with in-session serial recompilation:
  ```sql
  sys.utl_recomp.recomp_serial(schema => 'APEX_260100');
  ```

---

## 6. Ephemeral Container Pattern (`--rm`)

For one-off CLI operations (schema migrations, backups, exports):
```bash
podman run --rm -i \
  --network=host \
  -v "$(pwd):/workspace" \
  -w /workspace \
  container-registry.oracle.com/database/sqlcl:latest \
  APEX_PROXY_SCHEMA/password@localhost:1532/FREEPDB1
```

---

## 7. 🩺 Diagnostic Signatures & 1-Line Remedies

| Symptom / Error | Root Cause | 1-Line Remedy |
|:---|:---|:---|
| `ORA-00018` / `ORA-00020` | Exceeded session/process limit under concurrent workload | Run `ALTER SYSTEM SET processes=300 SCOPE=SPFILE;` and restart container. |
| `ORA-01109: database not open` | Pluggable database did not open automatically | Run `ALTER PLUGGABLE DATABASE FREEPDB1 OPEN; ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE;`. |
| `ORA-03114: not connected to ORACLE` | Datafile autoextend I/O flush timeout | Pre-allocate datafiles (`sysaux01.dbf` to 2048M) before running heavy scripts. |
| `ORA-00609: could not attach connection` | Parallel recompilation worker TCP timeout | Use `sys.utl_recomp.recomp_serial` instead of `recomp_parallel`. |
| Container status `unhealthy` | Oracle listener or healthcheck probe timed out | Inspect logs: `podman logs <container_id> --tail 50` to check database alert.log. |

