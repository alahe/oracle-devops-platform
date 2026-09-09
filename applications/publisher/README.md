[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📊 Oracle Analytics Publisher Applications & Catalog (`applications/publisher/`)

This directory is the **Single Source of Truth (SSoT)** for Oracle Analytics Publisher reports, RTF pixel-perfect templates, and data models. Its internal layout mirrors the Publisher catalog structure 1:1 (`/Custom/<Domain>/<ReportName>/`).

---

## 📁 Directory Anatomy

```text
applications/publisher/
├── .gitignore                         # Excludes binary *.xdoz and *.xdmz archives
├── README.md                          # Documentation (6 languages: EN, ET, FI, SV, LV, LT)
└── Custom/
    └── Invoices/
        └── Invoice_Report/
            ├── Invoice_Report.xdo/       # Git-tracked report package
            │   ├── template.rtf          # Accessible PDF/UA-1 RTF template
            │   ├── template_et.xlf       # Estonian XLIFF translations
            │   ├── template_fi.xlf       # Finnish XLIFF translations
            │   └── _manifest.xml         # Publisher report manifest
            └── Invoice_DataModel.xdm/    # Git-tracked data model package
                ├── datamodel.sql         # Clean SQL data collection query
                ├── datamodel.xml         # XML data model bound to ALISE_APP_DB
                └── sample_data.xml       # Sample data for offline and CI testing
```

> [!IMPORTANT]
> **GitOps Rule:** Git only tracks human-readable, diff-friendly source files. Binary export archives (`*.xdoz` and `*.xdmz`) are transient build artifacts and are automatically generated Just-In-Time (JIT) in memory by the deployment script.

---

## 🚀 CLI Commands

### 1. Scaffold a New Report
Generate a complete, standard-compliant report and data model structure in one command:
```bash
./scripts/publisher/create-report.sh Custom/Billing/Monthly_Statement "Monthly Statement"
```

### 2. Deploy to Publisher Server
Deploy an individual report or all reports via REST API:
```bash
# Deploy report (Idempotent upsert)
./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --mode rest

# Deploy with immediate server-side PDF test rendering:
./scripts/publisher/deploy-template.sh Custom/Invoices/Invoice_Report --render
```

### 3. Rotate Passwords & Credentials
Manage passwords in Oracle SEPS Wallet (`cwallet.sso`):
```bash
./scripts/rotate-password.sh publisher dev     # Rotates bip_developer
./scripts/rotate-password.sh publisher user    # Rotates bip_user
./scripts/rotate-password.sh publisher admin   # Rotates bip_admin
```

---

## 🛡️ Security Roles & SEPS Wallet

| User | Group / Roles | SEPS Wallet Alias | Purpose |
| :--- | :--- | :--- | :--- |
| `bip_developer` | `XMLP_DEVELOPER`, `XMLP_TEMPLATE_DESIGNER` | `PUBLISHER_DEVELOPER` | Template & Data Model authoring in `/Custom/` |
| `bip_user` | `XMLP_SCHEDULER`, `XMLP_ANALYZER` | `PUBLISHER_USER` | Running reports, viewing/deleting job history |
| `bip_admin` | `XMLP_ADMIN` | `PUBLISHER_ADMIN` | BIP catalog administration (no WebLogic console) |
