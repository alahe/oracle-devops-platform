[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# ⚙️ Vidinių Scenarijų Katalogas (`scripts/internal/`)

Pagal **Rule 3 (Directory Layout Rule for Scripts)** šiame kataloge yra pagalbiniai automatizavimo varikliai, profilių analizatoriai, duomenų bazių inicializatoriai, automatiniai diegimo žingsniai ir SQL failai, kuriuos viduje naudoja aplinkos orkestratorius (`setup-all.sh`).

> 💡 **Kūrėjo Įrankiai:** Kasdieniai CLI įrankiai (`get-password.sh`, `check-urls.sh`, `check-wallet.sh`, `create-developer.sh`, `register-connections.sh`) yra tiesiogiai kataloge [`scripts/`](../README.lt.md).

---

## 📂 Vidinių Scenarijų Sąrašas

### 📦 1. Profilių Variklis ir Topologijos Valdymas
| Scenarijus | Aprašymas |
| :--- | :--- |
| **[load-profile.sh](load-profile.sh)** | Dinaminis YAML profilių analizatorius (`config/profiles/*/*.yaml`). Taiko 3 lygių prioritetų hierarchiją konteinerių atvaizdams ir ZIP URL. |
| **[resolve-topology.sh](resolve-topology.sh)** | Kelių egzempliorių topologijos valdytojas (`config/topology.yaml`). Priskiria nekonfliktuojančius prievadus (`1532`, `1533`, `8443`, `8444`). |
| **[apply-profile-users.sh](apply-profile-users.sh)** | Dinaminis DB vartotojų administravimas, rolių priskyrimas (`DB_DEVELOPER_ROLE`, `CONSOLE_DEVELOPER`), ORDS REST susiejimas ir APEX vartotojai. |

### 🚀 2. APEX ir ORDS Variklio Diegimas
| Scenarijus | Aprašymas |
| :--- | :--- |
| **[install-apex.sh](install-apex.sh)** | Automatizuotas APEX variklio diegimas (`@apexins.sql`) į Oracle Free DB 23ai egzempliorius. |
| **[install-ords-standalone.sh](install-ords-standalone.sh)** | Atskiras ORDS diegimo scenarijus Linux serverių diegimams be Docker. |
| **[deploy-apex-apps.sh](deploy-apex-apps.sh)** | Nuoseklus APEX programų importuotojas failams iš `binaries/apex_apps/`. |
| **[deploy-apex.sql](deploy-apex.sql)** | SQLcl PL/SQL apvalkalas APEX programų SQL eksportams importuoti. |

### 🔌 3. Profiliais Paremtas Egzemplioriaus Inicijavimas
| Scenarijus / SQL | Apraksts |
| :--- | :--- |
| **[init-db-instance.sh](init-db-instance.sh)** | Bendras profiliu valdomas duomenų bazės inicializavimo scenarijus bet kuriam profiliui (`proxy`, `appinfra`, `bizapp`, `cicd`). |
| **[init-db-instance.sql](init-db-instance.sql)** | Profiliu valdomas PL/SQL scenarijus, konfigūruojantis atminties parametrus, lentelių erdves ir REST tinklo ACL. |

### 🔑 4. Sauga, Paslaptys ir Sertifikatai
| Scenarijus | Aprašymas |
| :--- | :--- |
| **[create-wallet.sh](create-wallet.sh)** | Sukuria Oracle SEPS (Secure External Password Store) automatinio prisijungimo pinigines (`cwallet.sso`). |
| **[export-ci-secrets.sh](export-ci-secrets.sh)** | Supakuoja vietinį SEPS Wallet kaip Base64 eilutę (`DB_WALLET_BASE64`), skirtą GitHub Secrets ir CI/CD procesams. |
| **[generate-passwords.sh](generate-passwords.sh)** | Generuoja atsitiktinius saugius slaptažodžius ir užregistruoja juos kaip Podman Secrets. |
| **[sanitize-logs.sh](sanitize-logs.sh)** | Srauto filtras stdout/stderr žurnalams; užmaskuoja paslaptis/žetonus (`token=***MASKED***`). Palaiko `DEBUG_LOG_UNSANITIZED=true` derinimui. |
| **[generate-local-certs.sh](generate-local-certs.sh)** | Sukuria vietinį Root CA ir SSL sertifikatus (`config/certs/`) ir įdiegia pasitikėjimą macOS, Windows arba WSL. |

### 💻 5. Konteinerizuoto Web IDE Inicijavimas
| Scenarijus | Aprašymas |
| :--- | :--- |
| **[init-web-ide.sh](init-web-ide.sh)** | Iš anksto sukonfigūruoja code-server nustatymus, SEPS Wallet sinchronizavimą ir SQL Developer ryšius Web IDE viduje (`web-ide`). |
| **[install-web-ide-extensions.sh](install-web-ide-extensions.sh)** | Įdiegia reikiamus ir pasirinktinius VS Code plėtinius (VSIX) Web IDE konteineryje. |

### ⚡ 6. Orkestravimas ir Pagrindiniai Optimizavimo Įrankiai
| Scenarijus | Aprašymas |
| :--- | :--- |
| **[common.sh](common.sh)** | Centrinė bendra biblioteka (spalvos, trukmės formatavimas, eigos atvaizdavimas, signalų apdorojimas ir pigz suspaudimas). |
| **[generate-compose-override.sh](generate-compose-override.sh)** | Dinaminis Podman Compose pakeitimo generatorius (`podman-compose.override.yml`) pagal aktyvius profilius. |
| **[wait-db-healthy.sh](wait-db-healthy.sh)** | 2 fazių adaptyvus sveikatos tikrinimo variklis, tikrinantis konteinerio sveikatą, TCP klausytojus ir PDB READ WRITE būseną. |
| **[generate-setup-report.sh](generate-setup-report.sh)** | Našumo ir diegimo ataskaitų generatorius (JSON etalonai, ENV rodikliai ir architektūros audito ataskaitos). |
