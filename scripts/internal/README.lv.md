[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# ⚙️ Iekšējo Skriptu direktorijs (`scripts/internal/`)

Saskaņā ar **Rule 3 (Directory Layout Rule for Scripts)** šajā direktorijā atrodas automatizācijas dzinēji, profilu parsētāji, datubāzes inicializatori, automātiskie iestatīšanas soļi un SQL faili, ko iekšēji izmanto vides orķestrētājs (`setup-all.sh`).

> 💡 **Izstrādātāja Rīki:** Ikdienas CLI rīki (`get-password.sh`, `check-urls.sh`, `check-wallet.sh`, `create-developer.sh`, `register-connections.sh`) atrodas tieši mapē [`scripts/`](../README.lv.md).

---

## 📂 Iekšējo Skriptu saraksts

### 📦 1. Profilu Dzinējs un Topoloģijas Pārvaldība
| Skripts | Apraksts |
| :--- | :--- |
| **[load-profile.sh](load-profile.sh)** | Dinamisks YAML profilu parsētājs (`config/profiles/*/*.yaml`). Pielieto 3 līmeņu prioritāšu hierarhiju konteineru attēliem un ZIP URL. |
| **[resolve-topology.sh](resolve-topology.sh)** | Vairāku instanču topoloģijas pārvaldnieks (`config/topology.yaml`). Piešķir nekonfliktējošus portus (`1532`, `1533`, `8443`, `8444`). |
| **[apply-profile-users.sh](apply-profile-users.sh)** | Dinamiska DB lietotāju izveide, lomu piešķiršana (`DB_DEVELOPER_ROLE`, `CONSOLE_DEVELOPER`), ORDS REST kartēšana un APEX darba vietas lietotāji. |

### 🚀 2. APEX un ORDS Dzinēja Instalācija
| Skripts | Apraksts |
| :--- | :--- |
| **[install-apex.sh](install-apex.sh)** | Automatizēta APEX dzinēja instalēšana (`@apexins.sql`) Oracle Free DB 23ai instancēs. |
| **[install-ords-standalone.sh](install-ords-standalone.sh)** | Savrups ORDS instalēšanas skripts Linux serveru izvietošanai ārpus Docker. |
| **[deploy-apex-apps.sh](deploy-apex-apps.sh)** | Secīgs APEX lietotņu importētājs failiem no `binaries/apex_apps/`. |
| **[deploy-apex.sql](deploy-apex.sql)** | SQLcl PL/SQL ietvars APEX lietotņu SQL eksporta importēšanai. |

### 🔌 3. Uz profiliem Balstīta instances Inicializācija
| Skripts / SQL | Apraksts |
| :--- | :--- |
| **[init-db-instance.sh](init-db-instance.sh)** | Universāls profila vadīts datubāzes inicializācijas skripts jebkuram profilam (`proxy`, `appinfra`, `bizapp`, `cicd`). |
| **[init-db-instance.sql](init-db-instance.sql)** | Profila vadīts PL/SQL skripts, kas konfigurē atmiņas parametrus, tabultelpas un REST tīkla ACL. |

### 🔑 4. Drošība, Noslēpumi Un Sertifikāti
| Skripts | Apraksts |
| :--- | :--- |
| **[create-wallet.sh](create-wallet.sh)** | Izveido Oracle SEPS (Secure External Password Store) automātiskās pieteikšanās makus (`cwallet.sso`). |
| **[export-ci-secrets.sh](export-ci-secrets.sh)** | Iepako lokālo SEPS Wallet kā Base64 virkni (`DB_WALLET_BASE64`) priekš GitHub Secrets un CI/CD konveijeriem. |
| **[generate-passwords.sh](generate-passwords.sh)** | Ģenerē nejaušas drošas paroles un reģistrē tās kā Podman Secrets. |
| **[sanitize-logs.sh](sanitize-logs.sh)** | Plūsmas filtrs stdout/stderr žurnāliem; maskē noslēpumus/marķierus (`token=***MASKED***`). Atbalsta `DEBUG_LOG_UNSANITIZED=true` atkļūdošanai. |
| **[generate-local-certs.sh](generate-local-certs.sh)** | Ģenerē lokālo Root CA un SSL sertifikātus (`config/certs/`) un reģistrē uzticamību macOS, Windows vai WSL. |

### 💻 5. Konteinerizētās Web IDE Inicializācija
| Skripts | Apraksts |
| :--- | :--- |
| **[init-web-ide.sh](init-web-ide.sh)** | Iepriekš konfigurē code-server iestatījumus, SEPS Wallet sinhronizāciju un SQL Developer savienojumus Web IDE iekšienē (`web-ide`). |
| **[install-web-ide-extensions.sh](install-web-ide-extensions.sh)** | Instalē nepieciešamos un pielāgotos VS Code paplašinājumus (VSIX) Web IDE konteinerā. |

### ⚡ 6. Orķestrēšana Un kodola Optimizācijas Rīki
| Skripts | Apraksts |
| :--- | :--- |
| **[common.sh](common.sh)** | Galvenā koplietotā čaulas bibliotēka (krāsas, laika formatēšana, progresa attēlošana, signālu apstrāde un pigz saspiešana). |
| **[generate-compose-override.sh](generate-compose-override.sh)** | Dinamisks Podman Compose pārrakstīšanas ģenerators (`podman-compose.override.yml`) balstoties uz aktīvajiem profiliem. |
| **[wait-db-healthy.sh](wait-db-healthy.sh)** | 2 fāžu adaptīvās veselības pārbaudes dzinējs, kas pārbauda konteinera veselību, TCP klausītājus un PDB READ WRITE statusu. |
| **[generate-setup-report.sh](generate-setup-report.sh)** | Veiktspējas un iestatīšanas pārskatu ģenerators (JSON etaloni, ENV rādītāji un arhitektūras audita pārskati). |
