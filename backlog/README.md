[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📋 Oracle DevOps Platform — Architecture & Task Backlog

This directory hosts the project's modular **Task & Backlog System**, where architectural enhancements, features, and security components are tracked in structured Markdown files.

---

## 🧭 Backlog Structure & Lifecycle Rules

```text
backlog/
├── README.md               # Backlog rules, workflow, and status matrix
├── template.md             # Standard template for authoring new task specifications
├── todo/                   # Pending, planned, and in-progress tasks
└── done/                   # Implemented, tested, and verified features
```

### Lifecycle Workflow:
1. **Adding a New Task:** Copy [`template.md`](template.md) into `todo/` as `TASK-XXX-[name].md` and complete all sections.
2. **Implementation:** When work begins, update status in file header to `IN_PROGRESS`.
3. **Completion & Archival:** Once code is implemented, documented, and all tests pass 100%, move file to `done/`:
   ```bash
   mv backlog/todo/TASK-XXX-*.md backlog/done/
   ```
4. **Update Index:** Mark status as `✅ IMPLEMENTED` in the status matrix below.

---

## 📊 Summary Status Matrix

### 🟢 Implemented & Verified Features (`done/`)

| Task ID | Component & Feature | Status | Description |
| :--- | :--- | :---: | :--- |
| **[TASK-001](done/TASK-001-container-naming.md)** | Canonical Container Naming | ✅ DONE | Deterministic container prefixes and hostname topology. |
| **[TASK-002](done/TASK-002-auto-ords-install.md)** | Automated Standalone ORDS | ✅ DONE | Automated non-interactive ORDS installation. |
| **[TASK-003](done/TASK-003-single-source-of-truth.md)** | Single Source of Truth Config | ✅ DONE | Centralized `.env` and YAML profiles. |
| **[TASK-004](done/TASK-004-developer-role-automation.md)** | Oracle 23ai DB_DEVELOPER_ROLE | ✅ DONE | Least-privilege developer user provisioning. |
| **[TASK-005](done/TASK-005-ords-auto-rest-mapping.md)** | ORDS AutoREST API Auto-mapping | ✅ DONE | Automatic REST enablement on schemas. |
| **[TASK-006](done/TASK-006-seps-wallet-architecture.md)** | Zero-Trust Oracle SEPS Wallet | ✅ DONE | Passwordless database connections. |
| **[TASK-007](done/TASK-007-multi-cloud-deployment.md)** | Remote Multi-Cloud Automation | ✅ DONE | Deploy blueprints to Azure VM & OCI ADB. |
| **[TASK-008](done/TASK-008-dev-hub-spa.md)** | Developer Hub Web SPA | ✅ DONE | Zero-trust developer portal & 1-click clipboard. |
| **[TASK-009](done/TASK-009-multilingual-support.md)** | 6-Language Localization Engine | ✅ DONE | Full EN/ET/FI/SV/LV/LT parity across scripts and docs. |
