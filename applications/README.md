[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Packaged APEX Applications (`applications/`)

This directory is designated for declarative Oracle APEX applications defined using the [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/) or standard SQLcl split exports.

---

## 🚀 Usage

1. **Placing Applications:** Place custom application packages here (e.g. `applications/my_app/application.apx`).
2. **Automated Deployment:** During `./scripts/setup-all.sh`, the deployment engine (`scripts/internal/deploy-apex-apps.sh`) automatically scans this directory and imports valid APEX applications into the target workspace.
3. **Validation:**
   ```bash
   node .agents/skills/apexlang/tools/apexctl.mjs apexlang validate --app-path applications/<app_name>
   ```

> [!NOTE]
> **TO-BE Roadmap:** A fully declarative in-DB APEX version of DevHub (App 101) is planned for future release. All tooling, APEXlang compilers, and deployment pipelines are pre-configured.
