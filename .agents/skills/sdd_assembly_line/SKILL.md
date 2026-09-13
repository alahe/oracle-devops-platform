---
name: sdd_assembly_line
description: Guidelines for Spec-Driven Development (SDD), Self-Contained Systems (SCS), and the Agentic Assembly Line (Ralph Loops, Quality Gates, Session Trails).
---

# Spec-Driven Development & Agentic Assembly Line Framework

This skill operationalizes the engineering principles of **Julian Wood** (Spec-Driven Development — SDD), **Simon Martinelli** (Self-Contained Systems & Context Window Economics — SCS), and **Thomas Dohmke** (The Agentic Assembly Line — Entire.io / GitHub).

---

## 1. Core Principles & Workflow (The 3 Pillars)

### Pillar 1: Spec-Driven Development (Julian Wood)
- **No Code Without a Spec:** Never start generating application code before `requirements.md` (business intent, glossary, Given/When/Then acceptance criteria) and `design.md` (architecture, schema, APIs) are documented under `docs/specs/<domain>/`.
- **Pre-Implementation Contradiction Analysis:** Always verify requirements for logical contradictions, mutually exclusive flags (e.g. `-s` vs `--fresh`), and SLA conflicts before writing code.
- **Atomic Tasks:** Decompose work into granular tasks in `tasks.md` where each task specifies the exact verification command.

### Pillar 2: Self-Contained Systems (Simon Martinelli)
- **Bounded Context & Context Window Budget:** Keep each feature or service slice self-contained (UI, logic, and data sovereignty via Oracle PDB). A complete vertical slice must fit within the AI context window (< 300 lines of spec).
- **Asynchronous Data Integration:** Avoid synchronous RPC chains between databases. Use asynchronous replication (pull/push/events) instead of 2PC distributed transactions.

### Pillar 3: Agentic Assembly Line & Quality Gates (Thomas Dohmke)
- **Ralph Loop (Autonomous Feedback Loop):** When a test or script fails, the AI agent must inspect the failure output, formulate a minimal targeted patch, apply it, and re-run the verification command autonomously.
- **5 Evaluation Gates:** Every pull request and release must prove:
  1. 🛡️ *Security Gate:* Zero-Trust wallet compliance, regex input sanitization, zero plaintext secrets.
  2. 🧪 *Functional Gate:* 100% test pass rate across unit/integration suites.
  3. 🌐 *Localization Gate:* 6-language symmetry across EN, ET, FI, SV, LV, LT.
  4. 💻 *Portability Gate:* Rule 13 compliance across Windows, macOS, and Linux.
  5. ⚡ *Performance Gate:* FastStart recovery $\le$ 20s and documented benchmarks.
- **Session Trails (`.agents/trails/`):** Document major intent, model used, Ralph Loops traversed, and decisions into `.agents/trails/` as institutional Git memory.

### Pillar 4: 4-Part Iteration, Dry-Run Verification & Local Commit Standard (Rule 16)
- **4-Part Vibe Iterations (`MAJOR.MINOR.PATCH.BUILD`):** During active development, every discrete task or code modification must bump the 4th number via `./scripts/bump-iteration.sh` (e.g. `2.5.0.1` $\rightarrow$ `2.5.0.2`), which automatically triggers Dev Hub background compilation and gives the developer instant visual feedback.
- **Mandatory Dry-Run Verification:** Before committing any iteration, agents must execute dry-run tests (`./tests/unit/test-semantic-versioning.sh`, `./scripts/release.sh --dry-run`, `./scripts/check-pre-commit.sh`) to confirm all quality gates hold without regressions.
- **Mandatory Local Git Commit:** Every completed iteration MUST immediately be committed to local Git with a Conventional Commit message (e.g. `git commit -m "feat(...): ... (iter vX.Y.Z.W)"`). This creates an immutable local safety checkpoint before proceeding.
- **Mandatory Spec Synchronization:** In the same step, verify if UI, CLI flags, or logic changed. If so, immediately update the corresponding `docs/specs/<domain>/` files.
- **Automated Conventional Commit Release:** On `git push`, the pre-push hook analyzes all commits since the last release tag:
  - `BREAKING CHANGE:` / `feat!:` $\rightarrow$ **MAJOR** (`X.0.0`)
  - `feat:` $\rightarrow$ **MINOR** (`x.Y.0`)
  - `fix:` / `perf:` / `refactor:` $\rightarrow$ **PATCH** (`x.y.Z`)
  It normalizes `VERSION` to 3-part SemVer, updates `CHANGELOG.md`, creates an annotated Git tag (`vX.Y.Z`), and seeds the next development cycle at `X.Y.Z.1`.

---

## 2. Documentation Hierarchy & Lifecycle

To prevent repository rot and clarify what to persist:

1. **Living Specifications (`docs/specs/<domain>/`):** Permanent, Git-tracked system of record. Always keep synchronized with working code.
2. **Implementation Plans (`implementation_plan.md`):** Ephemeral, conversational scratchpads for aligning on file diffs before coding. **Do not commit to Git.**
3. **Session Trails (`.agents/trails/`):** Permanent audit logs summarizing major feature sessions, decisions, and the 5 Quality Gate results.

