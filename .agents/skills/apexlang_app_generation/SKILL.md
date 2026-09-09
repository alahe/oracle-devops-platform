---
name: apexlang_app_generation
description: Guidelines for generating Oracle APEX applications using Oracle APEXlang declarative DSL (.apx), application specifications, and multi-language tokens.
---

# Oracle APEXlang DSL: AI-Driven APEX Application Generation

This skill guides generating production-ready Oracle APEX applications, pages, shared components, and dynamic actions using Oracle's official **APEXlang** declarative Domain Specific Language (`.apx` files), SQLcl MCP Server integration, and the **AI Vibe-Coding Loop**.

> [!NOTE]
> **Official Oracle Documentation & Published EBNF Grammar:**
> - [Oracle APEX 26.1 APEXlang Reference Manual](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/) — Authoritative specification for `.apx` AST nodes, keywords, and compiler CLI flags.
> - [Official APEXlang EBNF Grammar (`apexlang.ebnf`)](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/apexlang.ebnf) — Machine-readable formal EBNF grammar file for grammar-constrained decoding (GBNF), AST parser generators, and static security analyzers.

---

## 1. 🎯 When to Use & Negative Routing

### Positive Triggers (Activate Immediately):
- Drafting or modifying APEX declarative DSL files (`application.apx`, `pages/*.apx`, `shared-components/*.apx`)
- Generating APEX forms, interactive grids, cards, master-detail regions, or modal dialogs
- Formatting and linting APEXlang files (`apexctl.mjs apexlang validate`)
- Deploying `.apx` applications to target PDBs via `./scripts/internal/deploy-apex-apps.sh`

### Negative Routing (Redirect to Specialized Skills):
| If the task is primarily about... | DO NOT handle here. Route immediately to: |
|:---|:---|
| Low-level APEXlang compiler package internals, catalogs, or AST contracts | `apexlang` (Official Oracle skill) |
| APEX developer user provisioning, Azure Entra ID SSO, or `APEX_LANG` | `apex_dev` |
| Exporting classic SQLcl split files or Liquibase project releases | `sqlcl_project` |
| Migrating legacy Oracle Forms 14c `.fmb` files to APEX | `oracle_forms_devops` |

---

## 2. The Modern APEX Vibe-Coding Architecture

```text
VS Code (Host Environment)
 ├── Antigravity AI / Claude Code extension     (AI Agent generating source & driving SQLcl)
 ├── Oracle SQL Developer extension             (Human DB browsing & connection manager)
 └── Git                                        (Version control, diff review & PRs)

SQLcl 26.1+
 ├── APEXlang compiler                          (apex validate / apex import / apex export)
 ├── SQLcl Projects                             (export / stage / release / gen-artifact)
 └── MCP Server (sql -mcp)                      (Controlled DB access restricted to DEV)
               │
               ▼
Oracle AI Database 23ai / 26ai (DEV)
 ├── Oracle APEX 26.1 Application Runtime
 └── ORDS 26.1+ (Serves app + REST APIs; REST-enabled schema required)
```

### 1.1 Why SQLcl & MCP is the Mandatory Canonical AI Driver (Rationale)

The pairing of **SQLcl and its Model Context Protocol (MCP) server (`sql -mcp`)** is the platform's mandatory architectural backbone for AI-driven development:

1. **Live Schema Grounding (Zero Hallucination Guarantee):**
   - Through `sql -mcp`, the AI agent queries live dictionary metadata (`USER_TAB_COLUMNS`, `USER_CONSTRAINTS`, `USER_PROCEDURES`) before drafting UI or PL/SQL code. The agent never guesses column names or types.
2. **Authoritative APEXlang Compiler & Parser:**
   - SQLcl 26.1+ is the canonical compiler for APEXlang (`apex validate`, `apex import`, `apex export`). The AI agent invokes validation tools via MCP to verify EBNF syntax before deploying to the database.
3. **Enterprise Security Sandbox (`SQLCL_RESTRICTION_LEVEL=1`):**
   - The MCP server isolates the AI agent's actions strictly to the DEV database schema, preventing unauthorized command execution on the host operating system.
4. **Clean Division of Responsibility:**
   - **AI Agent:** Generates declarative `.apx` DSL and PL/SQL packages, driving SQLcl via MCP.
   - **Human Developer:** Browses tables, views, and execution plans using **Oracle SQL Developer for VS Code**, reviewing clean Git diffs before production deployment.

### 1.2 Published EBNF Grammar & Grammar-Constrained Decoding (GBNF)

*(Inspired by Kris Rice, SVP Software Development, Oracle Database)*

With the publication of the official machine-readable [APEXlang EBNF Grammar (`apexlang.ebnf`)](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/apexlang.ebnf), APEXlang transitions from an informal convention into a **strict, enforceable software engineering contract**:

1. **Grammar-Constrained Decoding (GBNF at Token Sampling Level):**
   - In local and enterprise AI inference engines (e.g. `llama.cpp`, DGX clusters with Nemotron, Claude/Codex APIs with constrained decoding), the EBNF grammar is converted to GBNF.
   - **The model physically cannot emit invalid property keys, malformed enums, or unclosed brackets.** The "looks plausible but won't import" failure mode is eliminated down to 0% by construction.
2. **Deterministic AST Static Security Analysis:**
   - Security tools walk the Abstract Syntax Tree (AST) rather than brittle regex heuristics:
     - **Authorization Schemes:** Verifies `@ADMIN_ROLE` or named security scheme is present on sensitive components.
     - **Frame Embedding:** Enforces `embedInFrames: deny` or `allowSameOrigin`.
     - **Session State:** Asserts `sessionStateProtection: enabled` with SHA-2+ hash algorithms.
     - **HTML Escaping:** Asserts `htmlEscapingMode: extended`.
     - **Reference Integrity:** Validates all component references strictly begin with `@` (e.g., `@THEME_42`).
3. **Structural AST Diffing:**
   - Code reviews and CI/CD pipelines compare AST nodes across versions, guaranteeing structural integrity across APEX upgrades.

---

## 2. Direct vs. Indirect Generation & "Low-Code as Code"

*(Inspired by Justin Miller, Kris Rice & Cristina Varas)*

Low-code development is transitioning from visual drag-and-drop Page Designer sessions into **"Low-Code as Code"** — a versionable, automatable, AI-assisted engineering workflow where full enterprise applications are built without dragging a single component.

> [!TIP]
> **The Intent-Driven Abstraction Engine ("Generate what you want to own, own what you generate"):**
> - **Direct Generation (Fragile):** LLM generates 10,000s of lines of raw imperative full-stack glue (React, Node, custom session managers). Every line of generated glue code must be owned and maintained by your team. Six months later, dependencies rot, security CVEs emerge, and framework churn forces expensive rewrites.
> - **Indirect Generation (APEXlang + APEX Engine):** LLM generates **10–50 lines of declarative intent** (`.apx` DSL). The battle-tested **Oracle APEX Implementation Engine** provides automatic session state protection, concurrency, authentication, accessibility, and UI rendering. Engine upgrades preserve application code without requiring a single line of refactoring.
> - **Governed Input vs. Governed Runtime (Kris Rice Principle):**
>   - **Parse-Time EBNF Guardrails:** The LLM emits declarative definitions constrained by a versioned EBNF grammar. Invalid syntax fails at parse time before touching the database.
>   - **Kernel-Level Security:** SQL injection is eliminated by automatic bind variables; Row-Level Security (RLS) and Virtual Private Database (VPD) policies reside in the database kernel and can never be bypassed by AI prompts.
> - **The "Edit–Validate–Import" Engineering Loop:**
>   1. **Edit:** Author/refactor `.apx` files in VS Code with AI.
>   2. **Validate:** Verify AST & schema compliance using `apex validate` / `apexctl` before touching the DB.
>   3. **Import:** Deploy into DEV via `apex import` in seconds with zero GUI drag-and-drop.
> - **Result:** 100x higher architectural correctness, 1000x higher human readability in Git diffs, and sustainable long-term enterprise lifecycle management (LCM).

---

## 3. The 6-Stage AI Vibe-Coding Loop

When designing, building, or modifying an APEX application, the AI agent must strictly follow the **6-Stage Vibe-Coding Loop**:

```mermaid
graph TD
  S1[1. Domain & Schema First<br/>Query live DB via MCP/SQLcl - DO NOT guess columns] --> S2[2. Business Logic First<br/>Write & compile PL/SQL packages - ensure VALID]
  S2 --> S3[3. Author APEXlang DSL<br/>Generate .apx source, spec & messages.apx]
  S3 --> S4[4. Validate Before Import<br/>Run apex validate / apexctl]
  S4 --> S5[5. Import into DEV<br/>apex import into DEV database]
  S5 --> S6[6. Present Git Diff<br/>Human developer inspects diff before test/PR]
```

### Stage Rules & Invariants:
1. **"Domain & Schema First" Rule (Simon Martinelli / AI Unified Process):** Fall in love with the business domain problem, not the code. Software generation starts with clear business intent and existing database truth. Never hallucinate column names or table schemas. Query the live database first via MCP (`DESCRIBE <table_name>`, `DBA_TAB_COLUMNS`).
2. **"Business Logic First" Rule (Yannick Loth / IVP):** Keep domain logic close to the data kernel. Eliminate accidental middle-tier DTO coupling by implementing domain business rules directly in PL/SQL packages (`*_API_PKG`). Compile and test PL/SQL packages in the database before building the UI, asserting `STATUS = 'VALID'`.
3. **"Declarative UI" Rule:** Express all UI in APEXlang DSL (`.apx` files) following the application spec (`.apexlang/application-spec.md`).
4. **"Validate Before Import" Rule:** Always run `node tools/apexctl.mjs apexlang validate --app-path <path>` (or `apex validate`) before sending code to the database. Fix all compiler diagnostics in code.
5. **"Safe Import to DEV":** Import the validated app into the local DEV database (`apex import` or `./scripts/internal/deploy-apex-apps.sh`).
6. **"Git Diff Review":** Hand a clean Git diff to the human developer for review and testing.

---

## 3. Directory Layout of an APEXlang Application

```text
applications/<app_name>/
├── .apexlang/
│   └── application-spec.md         # Generated composition and UX plan
├── application.apx                 # Application identity, auth, theme, parsing schema
├── pages/
│   ├── page-0001.apx               # Home / Dashboard page
│   ├── page-0010.apx               # Interactive Grid / Report
│   └── page-0011.apx               # Modal Form / Drawer
└── shared-components/
    ├── navigation.apx              # Top navigation menu entries
    ├── breadcrumbs.apx             # Breadcrumb tree and hierarchies
    ├── lists_of_values.apx         # Dynamic and static LOV definitions
    └── messages.apx                # Multi-language translation strings
```

---

## 4. Multi-Language Invariant (`messages.apx` + `&APP_TEXT$`)

> [!IMPORTANT]
> **Zero Hardcoded Text in Component Attributes:**
> Do NOT insert hardcoded language strings directly into button labels, region titles, or column headers. All user-facing strings must use `shared-components/messages.apx` and `&APP_TEXT$KEY.` substitution macros (supporting 🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT).

### `shared-components/messages.apx`:
```apx
sharedComponents.messages {
  message APP_TITLE {
    en: "DevOps Command Center"
    et: "DevOps Juhtimiskeskus"
    fi: "DevOps-Ohjauskeskus"
    sv: "DevOps Kontrollcenter"
    lv: "DevOps Vadības Centrs"
    lt: "DevOps Valdymo Centras"
  }
  message BTN_CREATE_ORDER {
    en: "Create Order"
    et: "Lisa Uus Tellimus"
    fi: "Luo Uusi Tilaus"
    sv: "Skapa Ny Order"
    lv: "Izveidot Pasūtījumu"
    lt: "Sukurti Užsakymą"
  }
}
```

### Component Reference in `pages/page-0010.apx`:
```apx
page 10 {
  title: "&APP_TEXT$APP_TITLE."
  regions {
    region orders_grid {
      title: "&APP_TEXT$ORDERS_REGION_TITLE."
      type: "Interactive Grid"
      source: "SELECT * FROM orders_v"
      buttons {
        button btn_create {
          label: "&APP_TEXT$BTN_CREATE_ORDER."
          action: "Redirect to Page in this Application"
          target: page 11
        }
      }
    }
  }
}
```

---

## 5. UI Architecture & Master-Detail Contracts

1. **Breadcrumb Hierarchy:**
   - Every non-modal user page must have a matching breadcrumb entry wired to `shared-components/breadcrumbs.apx`.
   - Child pages launched from a management hub or contextual report must explicitly declare their parent:
     `appearance { parentEntry: @breadcrumb.orders_hub }`.
2. **Master-Detail Context Propagation:**
   - Parent row selection must populate a hidden page item (`P10_SELECTED_ORDER_ID`) and refresh child regions via a **Dynamic Action** (`action: "Refresh Region"`).
   - **Prohibited:** Never refresh master-detail child regions by redirecting/reloading the full page via URL.
3. **Form Dialogs & Drawers:**
   - Create and edit forms should default to **Modal Dialog** or **Drawer** (`pageMode: "Modal Dialog"`).
   - Dialog close event triggers a Dynamic Action on the parent page to refresh the grid:
     `event: "Dialog Closed" -> action: "Refresh Region"`.

---

## 6. Automated Validation & Deployment CLI

```bash
# 1. Format and lint APEXlang files:
node .agents/skills/apexlang/tools/apexctl.mjs apexlang format --app-path applications/devhub
node .agents/skills/apexlang/tools/apexctl.mjs apexlang validate --app-path applications/devhub

# 2. Deploy compiled APEX application to target database:
./scripts/internal/deploy-apex-apps.sh
```

---

## 7. 🩺 Diagnostic Signatures & 1-Line Remedies

| Symptom / Error | Root Cause | 1-Line Remedy |
|:---|:---|:---|
| `EBNF_PARSER_ERROR` on `.apx` validate | Invalid keyword, unclosed braces, or illegal property | Run `node .agents/skills/apexlang/tools/apexctl.mjs apexlang validate --app-path <dir>` to see line number. |
| APEX import fails with `Schema not REST-enabled` | Workspace parsing schema missing ORDS enablement | Run `ORDS.ENABLE_SCHEMA(p_schema => 'SCHEMA_NAME');` as DBA. |
| `LIVE_RUNTIME_VALIDATION_REQUIRED_001` | App requires live database check but DB is offline | Start target DB container or verify connection alias with `./scripts/check-wallet.sh`. |
| Missing shared breadcrumb or navbar error | Child page references nonexistent parent in `appearance` | Verify entry exists in `shared-components/breadcrumbs.apx` or `navigation-menu.apx`. |

