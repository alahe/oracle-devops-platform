---
name: oracle_forms_devops
description: Guidelines for Oracle Forms 14c installation, HTML5 noVNC Forms Builder GUI, headless compilation, and APEX migration pipelines.
---

# Oracle Forms 14c (14.1.2): DevOps, noVNC & APEX Modernization

This skill covers running **Oracle Forms 14c (Forms Services 14.1.2)**, compiling forms headlessly, accessing the Web GUI via HTML5 noVNC, and modernizing legacy Forms into Oracle APEX applications.

---

## 1. Architecture & Port Map

- **Forms Runtime:** `http://localhost:9001/forms/frmservlet`
- **Test Form:** `http://localhost:9001/forms/frmservlet?form=test.fmx`
- **Forms Builder Web GUI (HTML5 noVNC):** `http://localhost:6082/vnc.html`
- **WebLogic AdminServer:** `http://localhost:7001`
- **Database Backend:** Port `1531`/`1532`/`1534`, PDB `FREEPDB1`, RCU prefix `FORMS_*`.

---

## 2. Forms Builder 14c & CLI Tooling

### 2.1 Web-Based Forms Builder (noVNC on Port 6082)
Launch Forms Builder 14c in the browser without installing X11 on the client host:
```bash
./scripts/forms/launch-builder.sh [module.fmb]
# Access GUI at: http://localhost:6082/vnc.html
```

### 2.2 Headless Batch Compilation (`compile-form.sh`)
Compile `.fmb`, `.mmb`, and `.pll` source files into binary `.fmx` executables without GUI:
```bash
./scripts/forms/compile-form.sh forms_apps/orders.fmb
```

### 2.3 Bi-directional XML Version Control (`form-to-xml.sh`)
Convert binary `.fmb` files to text XML for Git version control and code review:
```bash
# Convert FMB to XML:
./scripts/forms/form-to-xml.sh forms_apps/orders.fmb

# Convert XML back to FMB:
./scripts/forms/xml-to-form.sh forms_apps/orders.xml
```

---

## 3. APEX Migration Pipeline (Modernization to APEX)

### 3.1 1-Click Migration Bundle (`export-forms-for-apex.sh`)
Generates `apex_migration_bundle.zip` ready for upload into **Oracle APEX Application Migration Workshop**:
```bash
./scripts/forms/export-forms-for-apex.sh
```

### 3.2 Automated PL/SQL Extraction (`extract-forms-plsql.sh`)
Extracts Forms triggers and program units into clean, standalone database packages (`PKG_<FORM>_FORMS_LOGIC.sql`) for reuse in APEX:
```bash
./scripts/forms/extract-forms-plsql.sh forms_apps/orders.xml
```

---

## 4. Silent Installation & RCU Requirements

1. **Two-Stage FMW Silent Install:**
   - Stage 1: FMW Infrastructure 14.1.2 (`V1045135-01.zip`).
   - Stage 2: Forms and Reports 14.1.2 (`V1045121-01.zip`) with response file `forms_install.file`.
2. **RCU Repository Schemas:**
   - Initializes `FORMS_STB`, `FORMS_OPSS`, `FORMS_IAU`, and `FORMS_WLS` in PDB `FREEPDB1`.
