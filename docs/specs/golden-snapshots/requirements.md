# Golden Snapshot Disaster Recovery — Requirements Specification

- **Domain (SCS):** `golden-snapshots`
- **Version:** `1.0.0`
- **Status:** `Approved / In Production`
- **Methodology:** Julian Wood (Spec-Driven Development — SDD) & Simon Martinelli (SCS)

---

## 1. Business Context and Goals

Golden Snapshot Disaster Recovery allows developers, automation scripts, and automated CI pipelines to restore a full Oracle 23ai database, APEX, and ORDS environment into a known pristine state in ~15–20 seconds, bypassing time-consuming cold provisioning (~5-8 min).

### User Roles (Personas):
1. **Software Developer:** Restores the database to a clean slate in seconds following a failed schema migration or experimentation (`./scripts/setup-all.sh -s`).
2. **CI/CD Engineer:** Requires a clean, identical database prior to each test run.
3. **AI Agent (Copilot / Antigravity):** Uses snapshots as an automated rollback safety net before extensive codebase refactoring.

---

## 2. Domain Glossary (Ubiquitous Language)

| Term | Definition | Constraints / Notes |
| :--- | :--- | :--- |
| **Golden Snapshot** | Compressed archive of database data files in pristine baseline state. | Stored under `snapshots/`. |
| **FastStart (-s)** | Installation accelerator flag that restores the database from snapshot. | Mutually exclusive with `--fresh`. |
| **Quiesce** | Placing the database in a transactionally frozen state prior to archiving. | Ensures filesystem consistency. |

---

## 3. Functional Requirements & Acceptance Criteria

### [REQ-SNAP-01]: Deterministic Golden Snapshot Creation
- **Description:** The system must generate compressed archives of database volumes via `./scripts/snapshots/create-golden-snapshots.sh`.
- **Acceptance Criteria (Given/When/Then):**
  - **Given:** Database is healthy and initialized.
  - **When:** `create-golden-snapshots.sh` is invoked.
  - **Then:** Archive and metadata files with SHA-256 checksums are produced under `snapshots/`.

### [REQ-SNAP-02]: ~15-20s Instant FastStart Recovery
- **Description:** Command `./scripts/setup-all.sh -s` or Dev Hub FastStart recipe must restore database service in under 30 seconds.
- **Acceptance Criteria:**
  - **Given:** A valid golden snapshot exists.
  - **When:** `./scripts/setup-all.sh -s -y` is executed.
  - **Then:** Data volume is replaced from snapshot, container starts, and healthcheck passes in under 30s.

### [REQ-SNAP-03]: Snapshot Integrity and Version Validation
- **Description:** Snapshot restoration verifies compatibility with the active database engine (23ai Free) and blueprint topology.
- **Acceptance Criteria:**
  - **Given:** Snapshot is corrupted or targets an incompatible version.
  - **When:** Restoration is triggered.
  - **Then:** Execution aborts safely with clear remediation guidance offering `--fresh`.

---

## 4. Contradiction & Edge Case Analysis

| Requirement A | Requirement B | Potential Conflict | Solution / Priority |
| :--- | :--- | :--- | :--- |
| **[REQ-SNAP-02] (FastStart restore)** | **Fresh Start (--fresh)** | What happens if user passes both `-s` and `--fresh`? | Scripts and Dev Hub Setup Studio enforce strict mutual exclusion. |
