---
name: oracle_forms_devops
description: Guidelines for Oracle Forms 14c installation, HTML5 noVNC Forms Builder GUI, headless compilation, and APEX migration pipelines.
---

# Oracle Forms 14c (14.1.2): DevOps, noVNC & APEX Modernization

This skill covers running **Oracle Forms 14c (Forms Services 14.1.2)**, compiling forms headlessly, accessing the Web GUI via HTML5 noVNC, and modernizing legacy Forms into Oracle APEX applications.

---

## 1. When to Use & Negative Routing

### Positive Triggers (Activate this skill when:)
- Developing, compiling, or troubleshooting Oracle Forms 14c (`14.1.2`) applications.
- Accessing the in-browser Forms Builder Web GUI via HTML5 noVNC (`http://localhost:6082/vnc.html`).
- Running headless batch compilation of `.fmb`, `.mmb`, or `.pll` files (`compile-form.sh`).
- Converting binary Forms files (`.fmb`) to/from XML for Git version control (`form-to-xml.sh`, `xml-to-form.sh`).
- Exporting migration bundles for Oracle APEX Application Migration Workshop (`export-forms-for-apex.sh`).
- Extracting Forms PL/SQL business logic and triggers into clean database packages (`extract-forms-plsql.sh`).
- Working with Blueprint 5 (Legacy Stack Forms), Blueprint 6 (Hybrid Forms + APEX), or Blueprint 7 (Mega Enterprise Suite).

### Negative Routing (What NOT to do here:)
| Request / Intent | Do NOT handle here | Route to Skill |
|---|---|---|
| Developing APEX pages, themes, or workspace users | `apex_dev` | Use [apex_dev](file:///.agents/skills/apex_dev/SKILL.md) |
| Generating declarative APEX apps from `.apx` DSL | `apexlang_app_generation` | Use [apexlang_app_generation](file:///.agents/skills/apexlang_app_generation/SKILL.md) |
| Generating reports with Analytics Publisher | `oracle_publisher` | Use [oracle_publisher](file:///.agents/skills/oracle_publisher/SKILL.md) |
| Database container lifecycle, memory, or faststart | `oracle_containers` | Use [oracle_containers](file:///.agents/skills/oracle_containers/SKILL.md) |
| SEPS wallet passwords or credential rotation | `wallet_security_rotation` | Use [wallet_security_rotation](file:///.agents/skills/wallet_security_rotation/SKILL.md) |

---

## 2. Architecture & Port Map

| Component | Port / URL | Description |
|---|---|---|
| **Forms Runtime** | `http://localhost:9001/forms/frmservlet` | Web runtime servlet for launching `.fmx` applications |
| **Test Form** | `http://localhost:9001/forms/frmservlet?form=test.fmx` | Built-in verification form for sanity checking |
| **Forms Builder Web GUI** | `http://localhost:6082/vnc.html` | In-browser HTML5 noVNC desktop running Forms Builder 14c |
| **WebLogic AdminServer** | `http://localhost:7001` | FMW Domain AdminServer console |
| **Forms Managed Server** | `http://localhost:9001` | WLS managed server hosting `formsapp` |
| **Database Backend** | Ports `1531`/`1532`/`1534`, PDB `FREEPDB1` | Dedicated Oracle 23ai instance (`db-forms-oracle`) |

- **Profiles & Blueprints:** Profile `config/profiles/forms/forms-standard.yaml`, used by Blueprint 5, 6, and 7.
- **Repository Schema (RCU):** Prefix `FORMS_*` (`FORMS_STB`, `FORMS_OPSS`, `FORMS_IAU`, `FORMS_WLS`) created inside `FREEPDB1`.

---

## 3. Operational Playbooks & Step-by-Step Execution

### 3.1 Web-Based Forms Builder via HTML5 noVNC (Port 6082)
Launch the 14c Forms Builder in your browser without requiring local X11 or client software:
```bash
# Launch Forms Builder container with target FMB mounted:
./scripts/forms/launch-builder.sh forms_apps/orders.fmb

# Open browser to access GUI:
# http://localhost:6082/vnc.html
```

### 3.2 Headless Batch Compilation (`compile-form.sh`)
Compile `.fmb` (form), `.mmb` (menu), and `.pll` (library) source files into executable binaries (`.fmx`, `.mmx`, `.plx`) inside the container:
```bash
# Compile a single form module:
./scripts/forms/compile-form.sh forms_apps/orders.fmb

# Compile all forms in directory:
find forms_apps -name "*.fmb" -exec ./scripts/forms/compile-form.sh {} \;
```

### 3.3 Bi-directional XML Version Control (`form-to-xml.sh`)
Binary `.fmb` files cannot be diffed cleanly in Git. Convert them to readable XML before committing:
```bash
# 1. Convert binary FMB to human-readable XML:
./scripts/forms/form-to-xml.sh forms_apps/orders.fmb

# 2. Track orders.xml in Git:
git add forms_apps/orders.xml

# 3. Convert XML back to binary FMB on any host:
./scripts/forms/xml-to-form.sh forms_apps/orders.xml
```

### 3.4 1-Click APEX Migration Bundle (`export-forms-for-apex.sh`)
Prepare legacy Oracle Forms applications for modernizing into Oracle APEX:
```bash
# Generate the migration archive:
./scripts/forms/export-forms-for-apex.sh

# Resulting artifact:
#   artifacts/apex_migration_bundle.zip
```
Upload this zip file directly into **Oracle APEX > App Builder > Application Migration Workshop** to automatically extract blocks, items, lists of values (LOVs), and business logic.

### 3.5 Automated PL/SQL Logic Extraction (`extract-forms-plsql.sh`)
Extract embedded triggers (`WHEN-BUTTON-PRESSED`, `POST-QUERY`) and program units into clean, reusable database packages:
```bash
# Extract PL/SQL from XML representation:
./scripts/forms/extract-forms-plsql.sh forms_apps/orders.xml

# Generates:
#   forms_apps/PKG_ORDERS_FORMS_LOGIC.sql
```
Apply the generated package to the database using SQLcl:
```bash
./scripts/sqlcl.sh /@DB_FORMS_SYS @"forms_apps/PKG_ORDERS_FORMS_LOGIC.sql"
```

### 3.6 Silent Installation & RCU Provisioning
Automated silent provisioning executes two-stage installation:
1. **FMW Infrastructure 14.1.2** (`V1045135-01.zip`).
2. **Forms and Reports 14.1.2** (`V1045121-01.zip`) with silent response file.
3. **Repository Creation Utility (RCU):** Initializes `FORMS_*` schemas in PDB `FREEPDB1`.

---

## 4. Mandatory Rules & Strict Prohibitions (Anti-Patterns)

- ❌ **Prohibit Binary-Only Commits in Git:** Never commit raw binary `.fmb` or `.fmx` files to Git without generating and staging their `.xml` counterparts via `form-to-xml.sh`.
- ❌ **Prohibit Client-Side X11 Requirements:** Never require users or developers to configure local XQuartz or X11 forwarding; always use the in-browser HTML5 noVNC bridge (`:6082`).
- ❌ **Prohibit Legacy `sqlplus` in Automation:** Never invoke `sqlplus` in Forms scripts; always invoke SQLcl (`sql`) per Rule 6.
- ❌ **Prohibit Plaintext Passwords on Disk:** Never hardcode WebLogic (`weblogic`) or database passwords in scripts or response files. Decrypt dynamically via `./scripts/get-password.sh <ALIAS>`.
- ❌ **Prohibit Modifying FMW Home on Host:** All installation files and unzipping must happen strictly inside ephemeral container buffers per Rule 4.

---

## 5. Diagnostic Signatures & 1-Line Remedies (Troubleshooting)

| Error Code / Symptom | Root Cause | 1-Line Remediation |
|---|---|---|
| `FRM-40010: Cannot read form ...` | Missing `.fmx` compiled executable or wrong working directory | Run `./scripts/forms/compile-form.sh <form>.fmb` to generate `.fmx` in runtime path. |
| `FRM-30085: Unable to adjust form for output` | Compilation failed due to unresolved PLL library reference | Compile dependent `.pll` into `.plx` first with `compile-form.sh <lib>.pll`. |
| `noVNC: Failed to connect to server (port 6082)` | Web GUI container or websockify daemon is not running | Run `./scripts/forms/launch-builder.sh` to spin up the noVNC container bridge. |
| `RCU-6080: Connection to database failed` | Target PDB `FREEPDB1` is not healthy or port unreachable | Run `./scripts/internal/wait-db-healthy.sh db-forms-oracle 1534` to verify DB readiness. |
| `FRM-92050: Failed to connect to Server: /forms/lservlet` | WebLogic Forms managed server is stopped or starting up | Verify managed server status at `http://localhost:7001/console` or wait for healthcheck. |
| WebLogic AdminServer OOM (`OutOfMemoryError`) | Container RAM limit exceeded during FMW boot | Ensure host has at least 8 GB free RAM allocated to Podman/Docker machine. |
