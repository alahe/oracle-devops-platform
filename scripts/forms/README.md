[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Oracle Forms 14c Operational Scripts (`scripts/forms/`)

This directory provides operational tools for managing Oracle Forms 14c runtime environments, headless compilation, WebLogic domain diagnostics, and application deployments.

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
- **`deploy-forms-apps.sh`:** Deploys compiled Forms and menus into `/u01/oracle/forms_apps` inside the container.
  ```bash
  ./scripts/forms/deploy-forms-apps.sh
  ```
- **`status-forms.sh`:** Checks the health of Oracle Forms 14c and WebLogic runtime services.
  ```bash
  ./scripts/forms/status-forms.sh
  ```
