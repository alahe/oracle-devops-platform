# Blueprints & Dynamic Port Topology — Requirements Specification

- **Domain (SCS):** `blueprints-topology`
- **Version:** `1.0.0`
- **Status:** `Approved / In Production`
- **Methodology:** Julian Wood (Spec-Driven Development — SDD) & Simon Martinelli (SCS)

---

## 1. Business Context and Goals

The platform provides 12 canonical architectural blueprints (`config/blueprints/.env.*`), enabling engineering teams to declaratively configure containerized application stacks (APEX, ORDS, Analytics Publisher, Forms 14c, Web-IDE). Dynamic port topology ensures host port conflicts are detected and resolved automatically prior to container launch.

### User Roles (Personas):
1. **Solutions Architect:** Chooses application stacks tailored to project goals (e.g. BP 3 APEX Dev, BP 6 Publisher, BP 7 Forms).
2. **DevOps Engineer:** Switches blueprints (`module-toggle.sh`) without risking core database data loss.
3. **AI Agent:** Parses blueprint `.env` specifications and generates corresponding `podman-compose.override.yml`.

---

## 2. Domain Glossary (Ubiquitous Language)

| Term | Definition | Constraints / Notes |
| :--- | :--- | :--- |
| **Blueprint** | Declarative stack configuration file (`config/blueprints/.env.bp*`). | Contains no plaintext passwords or hardcoded host ports. |
| **Core Base Protection** | Principle ensuring the core database volume (`oracle-data`) persists across blueprint switches. | Prevents accidental data deletion. |
| **Dynamic Port Topology** | Automated host port resolution and availability validation (`resolve-topology.sh`). | Prevents `bind: address already in use` errors. |

---

## 3. Functional Requirements & Acceptance Criteria

### [REQ-BP-01]: Support for 12 Canonical Blueprints
- **Description:** The system must support 12 canonical blueprints (0 through 11) covering APEX, ORDS, Publisher, Forms, and Web-IDE combinations.
- **Acceptance Criteria (Given/When/Then):**
  - **Given:** Developer selects any blueprint (0–11).
  - **When:** `./scripts/module-toggle.sh bp<N>` is executed.
  - **Then:** Active `.env` links to target blueprint and `generate-compose-override.sh` compiles a valid compose file.

### [REQ-BP-02]: Dynamic Port Topology & Conflict Prevention
- **Description:** Prior to container orchestration, `resolve-topology.sh` verifies required host ports (1521, 8088, 8448, 9001, etc.) are available.
- **Acceptance Criteria:**
  - **Given:** A host port is occupied by another host process.
  - **When:** Port validation executes.
  - **Then:** System alerts the user and isolates or suggests alternate available ports.

### [REQ-BP-03]: Core Base Data Protection
- **Description:** Switching blueprints must never wipe the primary database storage volume (`oracle-data`) or developer schemas.
- **Acceptance Criteria:**
  - **Given:** Database contains developer schema tables.
  - **When:** Blueprint switches from BP 3 to BP 6.
  - **Then:** Datafiles remain intact and new services connect to existing PDBs.

---

## 4. Contradiction & Edge Case Analysis

| Requirement A | Requirement B | Potential Conflict | Solution / Priority |
| :--- | :--- | :--- | :--- |
| **[REQ-BP-01] (12 Blueprints)** | **[REQ-BP-02] (Ports)** | Running multi-database stacks could lead to port collisions. | Each blueprint utilizes strictly isolated port ranges and profiles. |
