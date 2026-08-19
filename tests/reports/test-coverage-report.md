# 📊 Testide Kaetuse Aruanne (Test Coverage Report)

See fail genereeritakse automaatselt skripti `./tests/generate-test-coverage-report.sh` poolt.
Aruanne analüüsib kõigi kaustades `scripts/` ja `scripts/internal/` asuvate Shell skriptide (`*.sh`) automaattestidega kaetust.

---

## 📅 Genereeritud: 2026-08-19 23:45:37

---

## 📂 1. Kasutaja Põhiskriptid (`scripts/`)

| Skript | Kaetuse Olek | Testkomplektid (Test Suites) |
| :--- | :--- | :--- |
| **`clean-golden-snapshots.sh`** | ✅ Kaetud | [`test-script-clean-golden-snapshots.sh`](test-script-clean-golden-snapshots.sh),[`test-e2e-system.sh`](test-e2e-system.sh) |
| **`clean-logs.sh`** | ✅ Kaetud | [`test-script-clean-logs.sh`](test-script-clean-logs.sh),[`test-e2e-system.sh`](test-e2e-system.sh) |
| **`create-golden-snapshots.sh`** | ✅ Kaetud | [`test-script-create-golden-snapshots.sh`](test-script-create-golden-snapshots.sh),[`test-e2e-system.sh`](test-e2e-system.sh) |
| **`install-web-ide-extensions.sh`** | ✅ Kaetud | [`test-script-install-web-ide-extensions.sh`](test-script-install-web-ide-extensions.sh) |
| **`register-connections.sh`** | ✅ Kaetud | [`test-script-register-connections.sh`](test-script-register-connections.sh),[`test-internal-installers-and-helpers.sh`](test-internal-installers-and-helpers.sh) |
| **`reset-all.sh`** | ✅ Kaetud | [`test-script-reset-all.sh`](test-script-reset-all.sh),[`test-e2e-system.sh`](test-e2e-system.sh) |
| **`restore-golden-snapshots.sh`** | ✅ Kaetud | [`test-script-restore-golden-snapshots.sh`](test-script-restore-golden-snapshots.sh),[`test-e2e-system.sh`](test-e2e-system.sh) |
| **`setup-all.sh`** | ✅ Kaetud | [`test-script-setup-all.sh`](test-script-setup-all.sh),[`test-compose-override-generation.sh`](test-compose-override-generation.sh),[`test-e2e-system.sh`](test-e2e-system.sh),[`test-subcomponent-services.sh`](test-subcomponent-services.sh) |
| **`sqlcl.sh`** | ✅ Kaetud | [`test-script-register-connections-sqlcl.sh`](test-script-register-connections-sqlcl.sh),[`test-e2e-system.sh`](test-e2e-system.sh),[`test-sqlcl-passwordless-connections.sh`](test-sqlcl-passwordless-connections.sh) |
| **`start-containers.sh`** | ✅ Kaetud | [`test-script-start-containers.sh`](test-script-start-containers.sh),[`test-e2e-system.sh`](test-e2e-system.sh) |
| **`test-local-ci.sh`** | ✅ Kaetud | [`test-script-test-local-ci.sh`](test-script-test-local-ci.sh),[`test-github-actions-local.sh`](test-github-actions-local.sh) |
| **`test-standalone-ords-emulation.sh`** | ✅ Kaetud | [`test-script-test-standalone-ords-emulation.sh`](test-script-test-standalone-ords-emulation.sh) |

---

## ⚙️ 2. Sisemised Abiskriptid (`scripts/internal/`)

| Skript | Kaetuse Olek | Testkomplektid (Test Suites) |
| :--- | :--- | :--- |
| **`internal/apply-apex-patch.sh`** | ✅ Kaetud | [`test-script-apply-apex-patch.sh`](test-script-apply-apex-patch.sh),[`test-internal-installers-and-helpers.sh`](test-internal-installers-and-helpers.sh) |
| **`internal/apply-profile-users.sh`** | ✅ Kaetud | [`test-script-apply-profile-users.sh`](test-script-apply-profile-users.sh),[`test-e2e-system.sh`](test-e2e-system.sh),[`test-profile-users-and-roles.sh`](test-profile-users-and-roles.sh) |
| **`internal/create-developer.sh`** | ✅ Kaetud | [`test-script-create-developer.sh`](test-script-create-developer.sh),[`test-internal-installers-and-helpers.sh`](test-internal-installers-and-helpers.sh) |
| **`internal/create-wallet.sh`** | ✅ Kaetud | [`test-script-create-wallet.sh`](test-script-create-wallet.sh),[`test-internal-installers-and-helpers.sh`](test-internal-installers-and-helpers.sh),[`test-browser-login.sh`](test-browser-login.sh) |
| **`internal/deploy-apex-apps.sh`** | ✅ Kaetud | [`test-script-deploy-apex-apps.sh`](test-script-deploy-apex-apps.sh),[`test-internal-installers-and-helpers.sh`](test-internal-installers-and-helpers.sh) |
| **`internal/export-ci-secrets.sh`** | ✅ Kaetud | [`test-script-export-ci-secrets.sh`](test-script-export-ci-secrets.sh),[`test-github-actions-local.sh`](test-github-actions-local.sh) |
| **`internal/generate-local-certs.sh`** | ✅ Kaetud | [`test-script-generate-local-certs.sh`](test-script-generate-local-certs.sh),[`test-e2e-system.sh`](test-e2e-system.sh) |
| **`internal/generate-passwords.sh`** | ✅ Kaetud | [`test-script-generate-passwords.sh`](test-script-generate-passwords.sh),[`test-e2e-system.sh`](test-e2e-system.sh),[`test-password-generator.sh`](test-password-generator.sh) |
| **`internal/init-db-instance.sh`** | ✅ Kaetud | [`test-script-init-db-instance.sh`](test-script-init-db-instance.sh),[`test-e2e-system.sh`](test-e2e-system.sh),[`test-instance-initializer.sh`](test-instance-initializer.sh) |
| **`internal/init-web-ide.sh`** | ✅ Kaetud | [`test-script-init-web-ide.sh`](test-script-init-web-ide.sh),[`test-web-ide-container.sh`](test-web-ide-container.sh) |
| **`internal/install-apex.sh`** | ✅ Kaetud | [`test-script-install-apex.sh`](test-script-install-apex.sh),[`test-internal-installers-and-helpers.sh`](test-internal-installers-and-helpers.sh) |
| **`internal/install-ords-standalone.sh`** | ✅ Kaetud | [`test-script-install-ords-standalone.sh`](test-script-install-ords-standalone.sh),[`test-internal-installers-and-helpers.sh`](test-internal-installers-and-helpers.sh) |
| **`internal/load-profile.sh`** | ✅ Kaetud | [`test-script-load-profile.sh`](test-script-load-profile.sh),[`test-compose-override-generation.sh`](test-compose-override-generation.sh),[`test-db-profiles-and-topology.sh`](test-db-profiles-and-topology.sh),[`test-e2e-system.sh`](test-e2e-system.sh),[`test-browser-login.sh`](test-browser-login.sh) |
| **`internal/register-connections-sqlcl.sh`** | ✅ Kaetud | [`test-script-register-connections-sqlcl.sh`](test-script-register-connections-sqlcl.sh),[`test-e2e-system.sh`](test-e2e-system.sh) |
| **`internal/register-connections.sh`** | ✅ Kaetud | [`test-script-register-connections.sh`](test-script-register-connections.sh),[`test-internal-installers-and-helpers.sh`](test-internal-installers-and-helpers.sh) |
| **`internal/resolve-topology.sh`** | ✅ Kaetud | [`test-script-resolve-topology.sh`](test-script-resolve-topology.sh),[`test-db-profiles-and-topology.sh`](test-db-profiles-and-topology.sh),[`test-e2e-system.sh`](test-e2e-system.sh) |
| **`internal/view-wallet-credential.sh`** | ✅ Kaetud | [`test-script-view-wallet-credential.sh`](test-script-view-wallet-credential.sh),[`test-subcomponent-services.sh`](test-subcomponent-services.sh),[`test-browser-login.sh`](test-browser-login.sh) |

---

## 📈 Kokkuvõttev Mõõdik (Summary Metrics)

- **Kogu skriptide arv (Total Scripts):** 29
- **Testidega kaetud skripte (Covered Scripts):** 29
- **Automaattestide kaetus (Test Coverage):** **100%**

