# DevOps Portal — Requirements Specification

- **Domain (SCS):** `devops-portal` (Dev Hub tab `⚡ DevOps`)
- **Version:** `1.1.0`
- **Status:** `Approved / In Production (v2.4.2)`
- **Methodology:** Julian Wood (Spec-Driven Development — SDD) & Simon Martinelli (SCS)

---

## 1. Business Context and Goals

The DevOps Portal is the central operational workstation of the **Oracle DevOps Platform**, enabling developers and system administrators to manage containers, databases, SEPS Wallets, certificates, and snapshots without memorizing low-level CLI syntax.

### User Roles (Personas):
1. **APEX / Database Developer:** Requires rapid 1-click local setup (FastStart ~15s), developer provisioning (`create-developer.sh`), and instant SQLcl terminal access.
2. **DevOps / System Administrator:** Requires deep environment reset (`reset-all.sh --system`), TLS certificate management, and CI/CD simulation.
3. **AI Pair Programmer (Copilot / Antigravity):** Communicates with the asynchronous bridge (`dev-hub-bridge.py`), inspects execution logs, and performs autonomous error remediation (Ralph Loop).

---

## 2. Domain Glossary (Ubiquitous Language)

| Term | Definition | Constraints / Notes |
| :--- | :--- | :--- |
| **FastStart (-s)** | Instant database restoration from pre-baked Golden Snapshot (~15-20s). | Mutually exclusive with `--fresh`. |
| **Fresh Start (--fresh)** | Cold installation from ground up without snapshots. | Removes existing data volumes prior to install. |
| **Dry-Run (--dry-run)** | Port and configuration validation without starting containers. | Makes zero persistent filesystem modifications. |
| **Deep Reset (--system)** | Complete destruction of containers, volumes, and networks (Zero-Trace). | Requires 2-stage explicit confirmation. |
| **Docked Console** | Slide-out, resizable ring-buffer terminal docked at screen bottom. | Persists across tab switching without stream drops. |

---

## 3. Functional Requirements & Acceptance Criteria

### [REQ-01]: Single Responsibility Architecture
- **Description:** The `⚡ DevOps` tab contains exclusively **platform lifecycle, management, and diagnostics commands**. All CI tests and reports reside on `🧪 Testing`.
- **Acceptance Criteria (Given/When/Then):**
  - **Given:** Developer opens Dev Hub tab `⚡ DevOps`.
  - **When:** Displayed tools and action cards are inspected.
  - **Then:** Exclusively lifecycle, wallet, core tools, snapshots, and diagnostic commands are rendered.

### [REQ-02]: Docked Terminal Console
- **Description:** Action cards must not stretch or distort during log streaming. Real-time stdout/stderr streams directly into a bottom-docked terminal.
- **Acceptance Criteria:**
  - **Given:** Developer triggers any DevOps command.
  - **When:** The process starts executing.
  - **Then:** Bottom docked console `#devops-docked-terminal` opens, live timer runs, and ANSI colorized logs stream in real-time.
  - **And:** Navigation across tabs remains uninterrupted.

### [REQ-03]: Guided Command Studios (Setup & Reset)
- **Description:** Conflicting flags (e.g. `-s` vs `--fresh`) must be represented as mutually exclusive radio pills with real-time command preview.
- **Acceptance Criteria:**
  - **Given:** Developer opens Setup Studio.
  - **When:** Developer selects `FastStart (-s)`.
  - **Then:** Live CLI preview updates (`./scripts/setup-all.sh -s -y`) with clear impact description.

### [REQ-04]: 2-Stage Destructive Confirmation Protection
- **Description:** Destructive operations (`reset-all.sh --system`) feature a warning outline and require explicit confirmation before execution.
- **Acceptance Criteria:**
  - **Given:** Developer selects `Deep System Purge (--system)`.
  - **When:** Confirmation checkbox is unchecked.
  - **Then:** Execution button is disabled and warning gate `#reset-studio-confirm-gate` displays.

### [REQ-05]: 1-Click AI Troubleshooting (Copilot & Antigravity)
- **Description:** When an execution error occurs, the terminal provides 1-click AI context escalation.
- **Acceptance Criteria:**
  - **Given:** Execution yields an error (`exit_code != 0` or `ORA-*`).
  - **When:** User clicks `🤖 Ask AI for solution`.
  - **Then:** Copilot / Antigravity panel opens pre-populated with command name, last 25 lines of logs, and troubleshooting context.

### [REQ-06]: 4-Part Iteration & Automated Semantic Release (Rule 16)
- **Description:** Development steps bump the 4th build number in `VERSION` (`2.5.0.X`), recompile Dev Hub, and show live progress.
- **Acceptance Criteria:**
  - **Given:** Developer implements an atomic change.
  - **When:** `./scripts/bump-iteration.sh` executes.
  - **Then:** Version increments in `VERSION` and Dev Hub compiles in background.

### [REQ-07]: Smart Adaptive Landing & Pinned Home Tab
- **Description:** Developers can pin their preferred starting tab with 1 click, bypassing static onboarding documentation on repeated visits.
- **Acceptance Criteria:**
  - **Given:** Developer visits portal without URL query parameters.
  - **When:** Tab has been pinned via `📌 Set as Home`.
  - **Then:** Portal loads directly to the pinned view with active pin indicator.

### [REQ-08]: Podman Virtual Machine Engine & Container Lifecycle Automation
- **Description:** Provide zero-friction 1-click startup and recovery for Podman virtual machines (AppleHV on macOS / WSL2 on Windows) and container stacks directly inside Dev Hub.
- **Acceptance Criteria (Given/When/Then):**
  - **Given:** Podman virtual machine is inactive or stopped.
  - **When:** Developer views the Podman tab in Dev Hub.
  - **Then:** Dynamic primary CTA displays `🚀 Start Podman Machine` and an empty-state hero banner `#podman-empty-hero` replaces dry error messages.
  - **When:** Developer clicks `🚀 Start Podman Machine` or chooses `⚡ Start Podman & Services`.
  - **Then:** Underlying VM is started via `podman machine start`, followed by container stack startup (`start-containers.sh`) in the bottom docked console with live streaming.
  - **And:** System resources and container tables hot-sync automatically upon completion.

---

## 4. Contradiction & Edge Case Analysis

| Requirement A | Requirement B | Potential Conflict | Solution / Rule |
| :--- | :--- | :--- | :--- |
| **FastStart (-s)** | **Fresh Start (--fresh)** | Restoring snapshot while ignoring snapshots is mutually contradictory. | Radio pill mode enforces single selection. CLI aborts with validation error if both are passed. |
| **Dry-Run (--dry-run)** | **Fresh Start (--fresh)** | Simulation must not destroy volumes. | In dry-run mode, deletion logic is strictly suppressed. |

---

## 5. Non-Functional Requirements (NFR)

1. **Security (Zero-Trust):** Strictly prohibits storing plaintext credentials on disk. Usernames are sanitized with `^[a-zA-Z0-9_]{3,30}$`.
2. **Browser Performance (DOM Ring-Buffer):** Terminal buffer caps at 1500 lines to prevent DOM bloat.
3. **Local Audit Logging (Rule 1.2):** Full logs tee directly into local `install_logs/` (Git excluded).
