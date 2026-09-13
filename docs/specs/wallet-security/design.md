# Zero-Trust SEPS Wallet — Technical Design & Architecture

- **Domain (SCS):** `wallet-security`
- **Referenced Requirements:** `docs/specs/wallet-security/requirements.md`
- **Methodology:** Simon Martinelli (SCS Architecture) & Julian Wood (SDD Design)

---

## 1. Architectural Overview & Bounded Context

Credential security and the Oracle SEPS wallet comprise an autonomous **Self-Contained System (SCS)** bounded context. This subsystem manages database secret lifecycles, encrypted storage at rest, and runtime in-memory retrieval strictly conforming to Zero-Trust architecture.

```mermaid
flowchart TD
    subgraph Storage["🔐 Encrypted Storage (wallet/)"]
        direction TB
        SSO["cwallet.sso<br/>(Auto-Login, AES-256)"]
        P12["ewallet.p12<br/>(PKCS#12 Master)"]
    end

    subgraph Memory["🧠 JIT In-Memory Layer (Runtime)"]
        direction TB
        MKSTORE["mkstore CLI / Oracle OCI<br/>(In-Memory Decryption)"]
        SECRETS["In-Memory Secrets<br/>(Destroyed on Exit)"]
        MKSTORE --> SECRETS
    end

    subgraph Consumers["🚀 Zero-Trust Consumers"]
        direction TB
        SQLCL["SQLcl CLI<br/>(./scripts/sqlcl.sh /@ALIAS)"]
        DEVHUB["Dev Hub / Bridge<br/>(get-password.sh)"]
        VSCODE["VS Code SQL Developer<br/>(Keytar / Keychain)"]
    end

    Storage -->|Host Machine Key| Memory
    Memory --> Consumers
```

---

## 2. Component Contracts and Interfaces

### 2.1. Wallet Credential Reader API (`get-password.sh`)
- **Command:** `./scripts/get-password.sh <ALIAS>`
- **Input:** TNS Wallet alias (e.g. `DB_DEV`, `DB_SYS`, `DB_APEX_ADMIN`)
- **Output:** Decrypted password to standard output (or exit code 1 on error).
- **Security Contract:** Passwords are never persisted to disk, caching files, or terminal logs.

### 2.2. Passwordless SQLcl Authentication
- **Command:** `./scripts/sqlcl.sh /@<ALIAS>`
- **Environment:**
  - `TNS_ADMIN=$WORKSPACE_DIR/wallet`
  - `JAVA_TOOL_OPTIONS=-Doracle.net.tns_admin=$TNS_ADMIN`
- **Outcome:** Instant authenticated session without password prompts.

---

## 3. Credential Rotation Lifecycle

```mermaid
sequenceDiagram
    autonumber
    participant Op as Developer / Admin
    participant Rot as rotate-credentials.sh
    participant DB as Oracle 23ai Free PDB
    participant Wal as SEPS Wallet (cwallet.sso)

    Op->>Rot: Trigger Rotation (ALIAS)
    Rot->>Rot: Generate 24-char high entropy secret
    Rot->>DB: ALTER USER alias IDENTIFIED BY new_pw
    DB-->>Rot: User altered (OK)
    Rot->>Wal: mkstore -modifyCredential ALIAS new_pw
    Wal-->>Rot: Wallet updated (OK)
    Rot->>DB: Test passwordless connection (/@ALIAS)
    DB-->>Rot: Connected (200 OK)
```

---

## 4. Non-Functional Requirements (NFRs)

- **NFR-SEC-1 (File Permissions):** Wallet files are strictly set to `chmod 0600` and wallet directory to `chmod 0700`.
- **NFR-SEC-2 (Git Exclusion):** Directory `wallet/` and files `*.sso`, `*.p12` are permanently in `.gitignore`.
- **NFR-SEC-3 (Zero-Trace Execution):** Ephemeral containers run with `--rm`, ensuring immediate memory cleanup and secret destruction upon process exit.
