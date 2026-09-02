# 📊 Testide Kaetuse Aruanne (Test Coverage Report)

See fail genereeritakse automaatselt skripti `./tests/generate-test-coverage-report.sh` poolt.
Aruanne analüüsib kõigi kaustades `scripts/` ja `scripts/internal/` asuvate Shell skriptide (`*.sh`) automaattestidega kaetust.

---

## 📅 Genereeritud: 2026-09-01 15:37:16

---

## 📂 1. Kasutaja Põhiskriptid (`scripts/`)

| Skript | Kaetuse Olek | Testkomplektid (Test Suites) |
| :--- | :--- | :--- |
| **`check-urls.sh`** | ✅ Kaetud | [`test-script-test-urls.sh`](../unit/test-script-test-urls.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh) |
| **`check-wallet.sh`** | ✅ Kaetud | [`test-multi-db-seps-wallet.sh`](../unit/test-multi-db-seps-wallet.sh),[`test-script-test-wallet-connections.sh`](../unit/test-script-test-wallet-connections.sh) |
| **`clean-logs.sh`** | ✅ Kaetud | [`test-script-clean-logs.sh`](../unit/test-script-clean-logs.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh) |
| **`create-developer.sh`** | ✅ Kaetud | [`test-script-create-developer.sh`](../unit/test-script-create-developer.sh),[`test-internal-installers-and-helpers.sh`](../integration/test-internal-installers-and-helpers.sh) |
| **`deploy-blueprint.sh`** | ✅ Kaetud | [`test-script-deploy-blueprint.sh`](../unit/test-script-deploy-blueprint.sh) |
| **`deploy-remote.sh`** | ✅ Kaetud | [`test-script-deploy-remote.sh`](../unit/test-script-deploy-remote.sh) |
| **`get-password.sh`** | ✅ Kaetud | [`test-multi-db-seps-wallet.sh`](../unit/test-multi-db-seps-wallet.sh),[`test-script-get-password.sh`](../unit/test-script-get-password.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh),[`test-subcomponent-services.sh`](../integration/test-subcomponent-services.sh),[`test-browser-login.sh`](../test-browser-login.sh) |
| **`publish-image-to-artifactory.sh`** | ✅ Kaetud | [`test-apex-speedup-and-artifactory.sh`](../unit/test-apex-speedup-and-artifactory.sh) |
| **`publish-to-artifactory.sh`** | ✅ Kaetud | [`test-script-publish-to-artifactory.sh`](../unit/test-script-publish-to-artifactory.sh) |
| **`register-connections.sh`** | ✅ Kaetud | [`test-script-register-connections.sh`](../unit/test-script-register-connections.sh),[`test-vscode-wallet-connections.sh`](../unit/test-vscode-wallet-connections.sh),[`test-internal-installers-and-helpers.sh`](../integration/test-internal-installers-and-helpers.sh) |
| **`reset-all.sh`** | ✅ Kaetud | [`test-script-reset-all.sh`](../unit/test-script-reset-all.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh) |
| **`rotate-password.sh`** | ✅ Kaetud | [`test-password-rotation.sh`](../unit/test-password-rotation.sh) |
| **`setup-all.sh`** | ✅ Kaetud | [`test-apex-speedup-and-artifactory.sh`](../unit/test-apex-speedup-and-artifactory.sh),[`test-cli-blueprint-params.sh`](../unit/test-cli-blueprint-params.sh),[`test-compact-terminal-ux.sh`](../unit/test-compact-terminal-ux.sh),[`test-publisher-speedup.sh`](../unit/test-publisher-speedup.sh),[`test-script-setup-all.sh`](../unit/test-script-setup-all.sh),[`test-compose-override-generation.sh`](../integration/test-compose-override-generation.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh),[`test-subcomponent-services.sh`](../integration/test-subcomponent-services.sh) |
| **`sqlcl.sh`** | ✅ Kaetud | [`test-multi-db-seps-wallet.sh`](../unit/test-multi-db-seps-wallet.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh),[`test-sqlcl-passwordless-connections.sh`](../integration/test-sqlcl-passwordless-connections.sh) |
| **`start-containers.sh`** | ✅ Kaetud | [`test-script-start-containers.sh`](../unit/test-script-start-containers.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh) |
| **`test-browser-login.sh`** | ✅ Kaetud | [`test-all-components.sh`](../test-all-components.sh) |
| **`test-local-ci.sh`** | ✅ Kaetud | [`test-script-test-local-ci.sh`](../unit/test-script-test-local-ci.sh),[`test-github-actions-local.sh`](../integration/test-github-actions-local.sh) |

---

## ⚙️ 2. Sisemised Abiskriptid (`scripts/internal/`)

| Skript | Kaetuse Olek | Testkomplektid (Test Suites) |
| :--- | :--- | :--- |
| **`internal/apply-apex-patch.sh`** | ✅ Kaetud | [`test-compact-terminal-ux.sh`](../unit/test-compact-terminal-ux.sh),[`test-script-apply-apex-patch.sh`](../unit/test-script-apply-apex-patch.sh),[`test-internal-installers-and-helpers.sh`](../integration/test-internal-installers-and-helpers.sh) |
| **`internal/apply-profile-users.sh`** | ✅ Kaetud | [`test-script-apply-profile-users.sh`](../unit/test-script-apply-profile-users.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh),[`test-profile-users-and-roles.sh`](../integration/test-profile-users-and-roles.sh) |
| **`internal/artifactory-client.sh`** | ✅ Kaetud | [`test-artifactory-client.sh`](../unit/test-artifactory-client.sh),[`test-script-artifactory-client.sh`](../unit/test-script-artifactory-client.sh) |
| **`internal/blueprint-info.sh`** | ✅ Kaetud | [`test-compact-terminal-ux.sh`](../unit/test-compact-terminal-ux.sh) |
| **`internal/check-network-ports.sh`** | ✅ Kaetud | [`test-script-check-network-ports.sh`](../unit/test-script-check-network-ports.sh) |
| **`internal/check-prerequisites.sh`** | ✅ Kaetud | [`test-script-check-prerequisites.sh`](../unit/test-script-check-prerequisites.sh) |
| **`internal/common.sh`** | ✅ Kaetud | [`test-artifactory-client.sh`](../unit/test-artifactory-client.sh),[`test-compact-terminal-ux.sh`](../unit/test-compact-terminal-ux.sh),[`test-custom-image-naming-pattern.sh`](../unit/test-custom-image-naming-pattern.sh),[`test-script-artifactory-client.sh`](../unit/test-script-artifactory-client.sh),[`test-script-common.sh`](../unit/test-script-common.sh),[`test-script-snapshot-resolver.sh`](../unit/test-script-snapshot-resolver.sh),[`test-snapshot-resolver.sh`](../unit/test-snapshot-resolver.sh) |
| **`internal/configure-external-ords-pool.sh`** | ✅ Kaetud | [`test-script-configure-external-ords-pool.sh`](../unit/test-script-configure-external-ords-pool.sh) |
| **`internal/create-wallet.sh`** | ✅ Kaetud | [`test-multi-db-seps-wallet.sh`](../unit/test-multi-db-seps-wallet.sh),[`test-script-create-wallet.sh`](../unit/test-script-create-wallet.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh),[`test-internal-installers-and-helpers.sh`](../integration/test-internal-installers-and-helpers.sh) |
| **`internal/credential-helper.sh`** | ✅ Kaetud | [`test-credentials-matrix.sh`](../unit/test-credentials-matrix.sh),[`test-password-rotation.sh`](../unit/test-password-rotation.sh) |
| **`internal/deploy-apex-apps.sh`** | ✅ Kaetud | [`test-script-deploy-apex-apps.sh`](../unit/test-script-deploy-apex-apps.sh),[`test-internal-installers-and-helpers.sh`](../integration/test-internal-installers-and-helpers.sh) |
| **`internal/download-publisher-binary.sh`** | ✅ Kaetud | [`test-script-download-publisher-binary.sh`](../unit/test-script-download-publisher-binary.sh) |
| **`internal/export-ci-secrets.sh`** | ✅ Kaetud | [`test-script-export-ci-secrets.sh`](../unit/test-script-export-ci-secrets.sh),[`test-github-actions-local.sh`](../integration/test-github-actions-local.sh) |
| **`internal/generate-compose-override.sh`** | ✅ Kaetud | [`test-script-generate-compose-override.sh`](../unit/test-script-generate-compose-override.sh) |
| **`internal/generate-dev-hub.sh`** | ✅ Kaetud | [`test-dev-hub-generation.sh`](../unit/test-dev-hub-generation.sh) |
| **`internal/generate-local-certs.sh`** | ✅ Kaetud | [`test-script-generate-local-certs.sh`](../unit/test-script-generate-local-certs.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh) |
| **`internal/generate-passwords.sh`** | ✅ Kaetud | [`test-script-generate-passwords.sh`](../unit/test-script-generate-passwords.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh),[`test-password-generator.sh`](../integration/test-password-generator.sh) |
| **`internal/generate-setup-report.sh`** | ✅ Kaetud | [`test-script-generate-setup-report.sh`](../unit/test-script-generate-setup-report.sh) |
| **`internal/i18n.sh`** | ✅ Kaetud | [`test-artifactory-client.sh`](../unit/test-artifactory-client.sh),[`test-i18n-translations.sh`](../unit/test-i18n-translations.sh),[`test-script-artifactory-client.sh`](../unit/test-script-artifactory-client.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh),[`test-multilingual-support.sh`](../test-multilingual-support.sh) |
| **`internal/init-db-instance.sh`** | ✅ Kaetud | [`test-script-init-db-instance.sh`](../unit/test-script-init-db-instance.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh),[`test-instance-initializer.sh`](../integration/test-instance-initializer.sh) |
| **`internal/init-forms-rcu.sh`** | ✅ Kaetud | [`test-script-status-forms.sh`](../unit/test-script-status-forms.sh) |
| **`internal/init-publisher-datasource.sh`** | ✅ Kaetud | [`test-script-init-publisher-datasource.sh`](../unit/test-script-init-publisher-datasource.sh) |
| **`internal/init-publisher-ords.sh`** | ✅ Kaetud | [`test-script-init-publisher-ords.sh`](../unit/test-script-init-publisher-ords.sh) |
| **`internal/init-publisher-rcu.sh`** | ✅ Kaetud | [`test-script-init-publisher-rcu.sh`](../unit/test-script-init-publisher-rcu.sh) |
| **`internal/init-web-ide.sh`** | ✅ Kaetud | [`test-script-init-web-ide.sh`](../unit/test-script-init-web-ide.sh),[`test-web-ide-container.sh`](../integration/test-web-ide-container.sh) |
| **`internal/install-apex.sh`** | ✅ Kaetud | [`test-apex-speedup-and-artifactory.sh`](../unit/test-apex-speedup-and-artifactory.sh),[`test-compact-terminal-ux.sh`](../unit/test-compact-terminal-ux.sh),[`test-script-install-apex.sh`](../unit/test-script-install-apex.sh),[`test-internal-installers-and-helpers.sh`](../integration/test-internal-installers-and-helpers.sh) |
| **`internal/install-forms.sh`** | ✅ Kaetud | [`test-script-status-forms.sh`](../unit/test-script-status-forms.sh) |
| **`internal/install-ords-standalone.sh`** | ✅ Kaetud | [`test-script-install-ords-standalone.sh`](../unit/test-script-install-ords-standalone.sh),[`test-internal-installers-and-helpers.sh`](../integration/test-internal-installers-and-helpers.sh) |
| **`internal/install-publisher-native.sh`** | ✅ Kaetud | [`test-script-install-publisher-native.sh`](../unit/test-script-install-publisher-native.sh) |
| **`internal/install-publisher.sh`** | ✅ Kaetud | [`test-publisher-speedup.sh`](../unit/test-publisher-speedup.sh),[`test-script-install-publisher.sh`](../unit/test-script-install-publisher.sh),[`test-script-internal-install-publisher.sh`](../unit/test-script-internal-install-publisher.sh) |
| **`internal/install-web-ide-extensions.sh`** | ✅ Kaetud | [`test-script-install-web-ide-extensions.sh`](../unit/test-script-install-web-ide-extensions.sh),[`test-web-ide-extensions.sh`](../unit/test-web-ide-extensions.sh) |
| **`internal/load-profile.sh`** | ✅ Kaetud | [`test-forms-profile-and-topology.sh`](../unit/test-forms-profile-and-topology.sh),[`test-script-load-profile.sh`](../unit/test-script-load-profile.sh),[`test-compose-override-generation.sh`](../integration/test-compose-override-generation.sh),[`test-db-profiles-and-topology.sh`](../integration/test-db-profiles-and-topology.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh),[`test-browser-login.sh`](../test-browser-login.sh) |
| **`internal/resolve-tls-mode.sh`** | ✅ Kaetud | [`test-resolve-tls-mode.sh`](../unit/test-resolve-tls-mode.sh),[`test-tls-scenarios.sh`](../test-tls-scenarios.sh) |
| **`internal/resolve-topology.sh`** | ✅ Kaetud | [`test-script-resolve-topology.sh`](../unit/test-script-resolve-topology.sh),[`test-db-profiles-and-topology.sh`](../integration/test-db-profiles-and-topology.sh),[`test-e2e-system.sh`](../integration/test-e2e-system.sh) |
| **`internal/run_blueprint_matrix_test.sh`** | ❌ Kaetus puudub | - |
| **`internal/sanitize-logs.sh`** | ✅ Kaetud | [`test-script-sanitize-logs.sh`](../unit/test-script-sanitize-logs.sh) |
| **`internal/snapshot-resolver.sh`** | ✅ Kaetud | [`test-artifactory-client.sh`](../unit/test-artifactory-client.sh),[`test-script-artifactory-client.sh`](../unit/test-script-artifactory-client.sh),[`test-script-snapshot-resolver.sh`](../unit/test-script-snapshot-resolver.sh),[`test-snapshot-resolver.sh`](../unit/test-snapshot-resolver.sh) |
| **`internal/test-forms-service.sh`** | ✅ Kaetud | [`test-script-status-forms.sh`](../unit/test-script-status-forms.sh) |
| **`internal/test-publisher-ds.sh`** | ✅ Kaetud | [`test-script-test-publisher-ds.sh`](../unit/test-script-test-publisher-ds.sh) |
| **`internal/test-standalone-ords-emulation.sh`** | ✅ Kaetud | [`test-script-test-standalone-ords-emulation.sh`](../unit/test-script-test-standalone-ords-emulation.sh) |
| **`internal/view-wallet-credential.sh`** | ✅ Kaetud | [`test-subcomponent-services.sh`](../integration/test-subcomponent-services.sh) |
| **`internal/wait-db-healthy.sh`** | ✅ Kaetud | [`test-script-wait-db-healthy.sh`](../unit/test-script-wait-db-healthy.sh) |

---

## 📈 Kokkuvõttev Mõõdik (Summary Metrics)

- **Kogu skriptide arv (Total Scripts):** 59
- **Testidega kaetud skripte (Covered Scripts):** 58
- **Automaattestide kaetus (Test Coverage):** **98%**

