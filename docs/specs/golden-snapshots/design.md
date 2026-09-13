# Golden Snapshot Disaster Recovery — Technical Design & Architecture

- **Domain (SCS):** `golden-snapshots`
- **Referenced Requirements:** `docs/specs/golden-snapshots/requirements.md`
- **Methodology:** Simon Martinelli (SCS Architecture) & Julian Wood (SDD Design)

---

## 1. Architectural Overview & Bounded Context

The Golden Snapshot subsystem is an autonomous **Self-Contained System (SCS)** that orchestrates physical database volume backup, archival, and fast restoration while preserving transactional integrity and Zero-Trust credential synchronization.

```mermaid
flowchart TD
    subgraph Engine["⚡ Recovery & Backup Engine (SCS)"]
        direction TB
        CREATE["create-golden-snapshots.sh<br/>(Transactional archival)"]
        RESTORE["restore-golden-snapshots.sh<br/>(FastStart recovery ~15-20s)"]
        CLEAN["clean-golden-snapshots.sh<br/>(Disk optimization)"]
    end

    subgraph Storage["💾 Snapshot Storage (snapshots/)"]
        direction TB
        ARCH["db-oracle-golden.tar.gz<br/>(Compressed datafiles)"]
        META["snapshot_meta.json<br/>(SHA-256 Checksums)"]
        ARCH --- META
    end

    subgraph Runtime["🐳 Podman & Database Runtime"]
        direction TB
        VOL["oracle-data volume<br/>(/opt/oracle/oradata)"]
        SEC["SEPS Wallet credentials<br/>(Zero-Trust sync)"]
        VOL --- SEC
    end

    CREATE --> Storage
    Storage --> RESTORE
    RESTORE --> Runtime
```

---

## 2. Process Flow & FastStart Execution

```mermaid
sequenceDiagram
    autonumber
    participant Dev as Developer / CI
    participant Script as setup-all.sh (-s)
    participant Snap as restore-golden-snapshots.sh
    participant Pod as Podman Engine
    participant DB as Oracle 23ai Free

    Dev->>Script: setup-all.sh -s -y
    Script->>Snap: Invoke recovery
    Snap->>Pod: Stop db-oracle container
    Snap->>Pod: Unpack archive to oradata volume
    Snap->>Pod: Start db-oracle
    Pod->>DB: Startup & PDB open
    Script->>DB: Health check (wait-db-healthy.sh)
    DB-->>Script: 200 OK (~18s total)
```

---

## 3. Non-Functional Invariants

- **Zero-Trust Wallet Synchronization:** The archived database state is verified against the auto-login keys in `wallet/`.
- **Ephemeral Cleanup:** Orphaned lock files and temporary archives are pruned automatically upon process exit.
