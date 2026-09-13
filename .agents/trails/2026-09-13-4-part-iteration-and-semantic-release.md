# Session Trail: 4-Part Iteration Versioning & Automated Semantic Release

- **Date:** 2026-09-13
- **Author:** Antigravity AI (Pair Programming with User)
- **Status:** Complete ✅

---

## 1. Intent & Context
During active development ("vibe coding"), developers need instant visual confirmation that discrete task changes are alive in the browser without losing track of semantic versioning or producing accidental major/minor version jumps.
Furthermore, the user raised two critical architectural questions:
1. *How does the version update, and how can we enable fine-grained iteration counts during development?*
2. *Should temporary implementation plans be saved to the repository or do they overlap with living specifications?*

---

## 2. Multi-Perspective Design Insights (The 4 Personas)
- **Software Engineer:** Keep `VERSION` as the authoritative Single Source of Truth (SSOT), Git-tracked. Avoid premature automatic commits that pollute history with micro-bumps.
- **Vibe Coder:** 4-part iteration number (`2.5.0.1` $\rightarrow$ `2.5.0.2`), background compiler execution, and live browser reflection with zero manual steps.
- **CI/CD Guru:** Analyze Conventional Commits (`feat:` $\rightarrow$ Minor, `fix:` $\rightarrow$ Patch, `BREAKING CHANGE:` $\rightarrow$ Major) automatically during `git push` via a pre-push hook, minting clean 3-part SemVer tags (`v2.5.0`).
- **Release Coordinator:** Maintain `CHANGELOG.md` auditability, enforce the 5 Quality Gates, and establish clear separation between living specs (`docs/specs/`), implementation scratchpads, and permanent session trails (`.agents/trails/`).

---

## 3. Changes Implemented

### Governance Rules & AI Skills
- **`.agents/AGENTS.md` (Rule 16 updated):**
  - Codified the 4-part iteration bumping rule (`MAJOR.MINOR.PATCH.BUILD`).
  - Mandated synchronous specification review (`docs/specs/`) whenever user-facing behavior, CLI arguments, or architecture changes.
  - Codified automated conventional commit semantic release on `git push`.
- **`.agents/skills/sdd_assembly_line/SKILL.md` (Pillar 4 added):**
  - Added documentation hierarchy guidelines: Living Specs (`docs/specs/`) = permanent truth; Implementation plans = ephemeral conversation scratchpads; Session Trails (`.agents/trails/`) = permanent audit memory.

### Core Automation Scripts
- **`scripts/bump-iteration.sh` (NEW):**
  - Increments the 4th iteration component in `VERSION` (e.g. `2.5.0.1` $\rightarrow$ `2.5.0.2`).
  - Automatically compiles `docs/dev-hub.html` in the background.
  - Supports `--commit` and `--dry-run`.
- **`scripts/release.sh` (NEW):**
  - Inspects Git commit history since the latest release tag.
  - Evaluates Conventional Commits to calculate target SemVer (`major`, `minor`, `patch`).
  - Updates `VERSION`, generates grouped `CHANGELOG.md` release notes, recompiles Dev Hub, and creates annotated Git tag (`vX.Y.Z`).
  - Supports `--dry-run`, `--auto`, `--push`.
- **`.githooks/pre-push` & `scripts/check-pre-commit.sh`:**
  - Automated pre-push hook that detects active 4-part development iterations and executes semantic release before pushing.

### Living Specification & Tasks
- **`docs/specs/devops-portal/requirements.md`:**
  - Added requirement `[REQ-06]: 4-Kohaline Tööiteratsioon ja Automaatne Semantiline Reliis (Rule 16)`.
- **`docs/specs/devops-portal/tasks.md`:**
  - Added task `TSK-DP-08` and marked complete.

### Dev Hub UI
- **`scripts/internal/dev_hub/assets/templates/layout.html`:**
  - Added 1-click CLI snippets for `bump-iteration.sh` and `release.sh --dry-run` to the Version Inspector modal.
  - Updated live version to `v2.5.0.2`.

---

## 4. Verification & Quality Gates
- **`tests/unit/test-semantic-versioning.sh`:** 6/6 tests PASS.
- **`tests/unit/test-dev-hub-generation.sh`:** PASS.
- **`tests/unit/test-spec-traceability.sh`:** PASS.
- **`tests/unit/test-filename-portability.sh`:** PASS (Rule 13).
- **`tests/unit/test-no-passwords-in-logs.sh`:** PASS (Rule 5).
