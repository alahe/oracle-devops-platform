[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Oracle Forms 14c Operational Scripts (`scripts/forms/`)

This directory provides operational tools for managing Oracle Forms 14c runtime environments, headless compilation, bidirectional XML conversion, roundtrip verification, WebLogic domain diagnostics, and application deployments.

---

## 🛠️ Available Scripts

- **`build-forms-image.sh`:** Builds the local `localhost/oracle-forms:14.1.2` container image.
  ```bash
  ./scripts/forms/build-forms-image.sh
  ```
- **`compile-form.sh`:** Compiles `.fmb` binary source forms into executable `.fmx` from CLI.
  ```bash
  ./scripts/forms/compile-form.sh /path/to/form.fmb
  ```
- **`form-to-xml.sh`:** Bidirectional FMB ↔ XML converter (Git diff and APEX Migration Workshop compatible).
  ```bash
  ./scripts/forms/form-to-xml.sh forms_apps/orders.fmb            # FMB -> XML
  ./scripts/forms/form-to-xml.sh --to-fmb forms_apps/orders.xml   # XML -> FMB
  ```
- **`test-fmb-xml-roundtrip.sh`:** Executes 2-pass roundtrip verification (`FMB -> XML(1) -> temp.fmb -> XML(2)`) and performs deep AST semantic diff.
  ```bash
  ./scripts/forms/test-fmb-xml-roundtrip.sh forms_apps/test.fmb
  ```
- **`deploy-forms-apps.sh`:** Deploys compiled Forms and menus into `/u01/oracle/forms_apps` inside the container.
  ```bash
  ./scripts/forms/deploy-forms-apps.sh
  ```
- **`status-forms.sh`:** Checks the health of Oracle Forms 14c and WebLogic runtime services.
  ```bash
  ./scripts/forms/status-forms.sh
  ```
