[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# ⚙️ Katalog för interna skript (`scripts/internal/`)

Enligt **Rule 3 (Directory Layout Rule for Scripts)** innehåller denna katalog kompletterande automationsmotorer, profilparser, databasinitierare, automatiserade installationssteg och SQL-filer som används internt av systemorkestreraren (`setup-all.sh`).

> 💡 **Utvecklarverktyg:** Dagliga CLI-verktyg (`get-password.sh`, `check-urls.sh`, `check-wallet.sh`, `create-developer.sh`, `register-connections.sh`) finns direkt i [`scripts/`](../README.sv.md).

---

## 📂 Referens för interna skript

### 📦 1. Profilhanterare & topologi
| Skript | Beskrivning |
| :--- | :--- |
| **[load-profile.sh](load-profile.sh)** | Dynamisk YAML-profilparser (`config/profiles/*/*.yaml`). Tillämpar 3-nivåers prioritetshierarki för containeravbildningar och ZIP-URL:er. |
| **[resolve-topology.sh](resolve-topology.sh)** | Topologihanterare för flera instanser (`config/topology.yaml`). Tilldelar icke-konflikterande portar (`1532`, `1533`, `8443`, `8444`). |
| **[apply-profile-users.sh](apply-profile-users.sh)** | Dynamisk DB-användaradministration, rolltilldelningar (`DB_DEVELOPER_ROLE`, `CONSOLE_DEVELOPER`), ORDS REST-mappning och APEX-användare. |

### 🚀 2. Installation av APEX & ORDS
| Skript | Beskrivning |
| :--- | :--- |
| **[install-apex.sh](install-apex.sh)** | Automatiserad installation av APEX-motorn (`@apexins.sql`) i standard Oracle Free DB 23ai-instanser. |
| **[install-ords-standalone.sh](install-ords-standalone.sh)** | Fristående ORDS-installationsskript för Linux-serverdriftsättning utanför Docker. |
| **[deploy-apex-apps.sh](deploy-apex-apps.sh)** | Sekventiell importör av APEX-applikationer för filer i `binaries/apex_apps/`. |
| **[deploy-apex.sql](deploy-apex.sql)** | SQLcl PL/SQL-omslag för att importera APEX-applikationsexporter i SQL-format. |

### 🔌 3. Profildriven instansinitiering
| Skript / SQL | Beskrivning |
| :--- | :--- |
| **[init-db-instance.sh](init-db-instance.sh)** | Generiskt profildrivet initieringsskript för valfri profil (`proxy`, `appinfra`, `bizapp`, `cicd`). |
| **[init-db-instance.sql](init-db-instance.sql)** | Profildrivet PL/SQL-skript som konfigurerar minnesparametrar, tabellutrymmen och REST-nätverks-ACL. |

### 🔑 4. Säkerhet, Hemligheter & certifikat
| Skript | Beskrivning |
| :--- | :--- |
| **[create-wallet.sh](create-wallet.sh)** | Genererar Oracle SEPS (Secure External Password Store) autologin-plånböcker (`cwallet.sso`). |
| **[export-ci-secrets.sh](export-ci-secrets.sh)** | Paketerar lokal SEPS Wallet som Base64-sträng (`DB_WALLET_BASE64`) för GitHub Secrets och CI/CD-pipelines. |
| **[generate-passwords.sh](generate-passwords.sh)** | Genererar starka slumplösenord och registrerar dem som Podman Secrets. |
| **[sanitize-logs.sh](sanitize-logs.sh)** | Strömfilter för stdout/stderr-loggar; maskerar hemligheter/tokens (`token=***MASKED***`). Stöder `DEBUG_LOG_UNSANITIZED=true` för nödfelsökning. |
| **[generate-local-certs.sh](generate-local-certs.sh)** | Genererar lokal Root CA och SSL-certifikat (`config/certs/`) och etablerar förtroende i macOS, Windows eller WSL. |

### 💻 5. Initiering av containerbaserad webb-ide
| Skript | Beskrivning |
| :--- | :--- |
| **[init-web-ide.sh](init-web-ide.sh)** | Förkonfigurerar code-server-inställningar, SEPS Wallet-synkronisering och SQL Developer-anslutningar inuti webb-IDE (`web-ide`). |
| **[install-web-ide-extensions.sh](install-web-ide-extensions.sh)** | Installerar nödvändiga och anpassade VS Code-tillägg (VSIX) inuti webb-IDE. |

### ⚡ 6. Orkestrering & Kärnoptimeringsverktyg
| Skript | Beskrivning |
| :--- | :--- |
| **[common.sh](common.sh)** | Centralt delat kärnbibliotek (färger, tidsformatering, framstegsrapportering, signalavbrottshantering och pigz-komprimering). |
| **[generate-compose-override.sh](generate-compose-override.sh)** | Dynamisk Podman Compose override-generator (`podman-compose.override.yml`) baserad på aktiva profiler och hemligheter. |
| **[wait-db-healthy.sh](wait-db-healthy.sh)** | 2-fas adaptiv hälsokontrollmotor som verifierar containerhälsa, TCP-lyssnare och PDB READ WRITE-status. |
| **[generate-setup-report.sh](generate-setup-report.sh)** | Generator för prestandamätningar och installationsrapporter (JSON-benchmarks, ENV-värden och arkitekturrapporter). |
