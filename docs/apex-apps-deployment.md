[ 🇬🇧 English ](apex-apps-deployment.md) | [ 🇪🇪 Eesti ](et/apex-apps-deployment.md) | [ 🇫🇮 Suomi ](fi/apex-apps-deployment.md) | [ 🇸🇪 Svenska ](sv/apex-apps-deployment.md) | [ 🇱🇻 Latviešu ](lv/apex-apps-deployment.md) | [ 🇱🇹 Lietuvių ](lt/apex-apps-deployment.md)

# Automated APEX Application Deployment

During database provisioning, the platform supports fully automated import, workspace configuration, and lifecycle management for multiple Oracle APEX applications.

---

## Application Deployment Workflow

1. **Application Storage:**
   Place your installable APEX application files (standard `.sql` export files as well as declarative **APEXlang** `.apx` / `.apex` files) into the `binaries/apex_apps/` directory.
2. **Import Engine (`deploy-apex-apps.sh`):**
   The internal automation helper **[`scripts/internal/deploy-apex-apps.sh`](../scripts/internal/deploy-apex-apps.sh)** sequentially installs all applications into Oracle APEX, automatically provisioning the target workspace (`PROXY_WORKSPACE`) and schema (`APEX_PROXY_SCHEMA`).
3. **Setup-All Integration (Step 8):**
   The primary environment provisioning script `./scripts/setup-all.sh` invokes this step automatically. Application deployment can be skipped entirely by passing the `--no-monitor-app` flag (or by configuring the corresponding variable in the `.env` file).

---

## Development and Version Control (APEXlang + AI Skill)

APEX applications (such as monitoring dashboards and enterprise tools) are version-controlled in dedicated repositories. For active development, use the Oracle APEX AI Skill **`oracle/skills/apex`**, which guides AI agents in reading, generating, and modifying declarative APEXlang text syntax.

> [!TIP]
> **Declarative Blueprint Specifications vs. Raw Glue Code Maintenance:**
> APEX blueprints and APEXlang (`.apx`) act as concise declarative specifications. Instead of generating massive codebases (where engineering teams must maintain 10,000+ lines of fragile UI glue code), the database-native security model and 0ms data latency deliver higher productivity and bulletproof security without technical debt.
