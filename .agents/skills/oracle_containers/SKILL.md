---
name: oracle_containers_devops
description: Guidelines for running official Oracle 23ai Free DB containers, managing resource limits, Vector Search, FastStart images, and in-container unzipping.
---

# Oracle Containers for DevOps: Oracle 23ai Free DB & Tooling

This skill provides guidelines for running official Oracle database containers (23ai Free DB, SQLcl, ORDS) for local development, CI/CD pipelines, and multi-architecture hosts.

---

## 1. Oracle 23ai Free DB Resource Limits & Invariants

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

## 4. Startup Performance: FastStart vs Standard DBCA

| Image / Profile | Startup Time | Technical Behavior |
| :--- | :--- | :--- |
| **`gvenzl/oracle-free:23-full-faststart`** | **~5 – 15 seconds** | **FastStart:** Pre-created database (`FREEPDB1`) mounted instantly in memory. |
| **`container-registry.oracle.com/database/free:latest`** | **~3 – 6 minutes** | **Standard DBCA:** First boot builds datafiles from scratch. |
| **Apple Silicon ARM64 Fallback** | Automatic | `load-profile.sh` maps `adb-free` (AMD64 only) to multi-arch `database/free:latest`. |

---

## 5. Ephemeral Container Pattern (`--rm`)

For one-off CLI operations (schema migrations, backups, exports):
```bash
podman run --rm -i \
  --network=host \
  -v "$(pwd):/workspace" \
  -w /workspace \
  container-registry.oracle.com/database/sqlcl:latest \
  APEX_PROXY_SCHEMA/password@localhost:1532/FREEPDB1
```
