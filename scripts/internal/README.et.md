[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# ⚙️ Sisemiste skriptide kataloog (`scripts/internal/`)

Vastavalt reeglile **Rule 3 (Directory Layout Rule for Scripts)** sisaldab käesolev kataloog abistavaid automaatikamootoreid, profiiliparsereid, andmebaasi initsialiseerijaid, automaatseid paigaldussamme ja SQL-faile, mida keskkonna orkestreerija (`setup-all.sh`) kasutab sisemiselt.

> 💡 **Arendaja Tööriistad:** Igapäevased CLI tööriistad (`get-password.sh`, `check-urls.sh`, `check-wallet.sh`, `create-developer.sh`, `register-connections.sh`) asuvad otse kaustas [`scripts/`](../README.et.md).

---

## 📂 Sisemiste skriptide viited

### 📦 1. Profiilimootor ja topoloogia haldus
| Skript | Kirjeldus |
| :--- | :--- |
| **[load-profile.sh](load-profile.sh)** | Dünaamiline YAML profiiliparser (`config/profiles/*/*.yaml`). Rakendab 3-tasemelist prioriteetide hierarhiat konteineripiltidele ja ZIP URL-idele. |
| **[resolve-topology.sh](resolve-topology.sh)** | Mitme baasieksemplari topoloogia haldur (`config/topology.yaml`). Eraldab mittepõrkuvad pordid (`1532`, `1533`, `8443`, `8444`). |
| **[apply-profile-users.sh](apply-profile-users.sh)** | Dünaamiline DB kasutajate loomine, rollide määramine (`DB_DEVELOPER_ROLE`, `CONSOLE_DEVELOPER`), ORDS REST kaardistus ja APEX töölaua kasutajate loomine. |

### 🚀 2. APEX ja ORDS mootori paigaldus
| Skript | Kirjeldus |
| :--- | :--- |
| **[install-apex.sh](install-apex.sh)** | Automatiseeritud APEX mootori paigaldus (`@apexins.sql`) standardsetesse Oracle Free DB 23ai instantsidesse. |
| **[install-ords-standalone.sh](install-ords-standalone.sh)** | Eraldiseisev ORDS paigaldusskript Linuxi serverpaigaldusteks väljaspool Dockerit. |
| **[deploy-apex-apps.sh](deploy-apex-apps.sh)** | Järjestikune APEX rakenduste importija kaustas `binaries/apex_apps/` olevatele failidele. |
| **[deploy-apex.sql](deploy-apex.sql)** | SQLcl PL/SQL ümbris APEX rakenduste SQL ekspordi importimiseks. |

### 🔌 3. Profiilipõhine Instantsi initsialiseerimine
| Skript / SQL | Kirjeldus |
| :--- | :--- |
| **[init-db-instance.sh](init-db-instance.sh)** | Geneeriline profiilipõhine andmebaasi initsialiseerija suvalisele profiilile (`proxy`, `appinfra`, `bizapp`, `cicd`). |
| **[init-db-instance.sql](init-db-instance.sql)** | Profiilipõhine PL/SQL skript, mis seadistab mäluparameetrid, tabeliruumid ja REST võrgu ACL-id. |

### 🔑 4. Turvalisus, saladused ja sertifikaadid
| Skript | Kirjeldus |
| :--- | :--- |
| **[create-wallet.sh](create-wallet.sh)** | Genereerib Oracle SEPS (Secure External Password Store) autologin rahakotid (`cwallet.sso`). |
| **[export-ci-secrets.sh](export-ci-secrets.sh)** | Pakib lokaalse SEPS Walleti Base64 kodeeritud stringiks (`DB_WALLET_BASE64`) GitHub Secrets ja CI/CD konveierite jaoks. |
| **[generate-passwords.sh](generate-passwords.sh)** | Genereerib kõrge entroopiaga juhuslikud paroolid ja registreerib need Podman Secrets saladustena. |
| **[sanitize-logs.sh](sanitize-logs.sh)** | Voo filter stdout/stderr logidele; maskeerib saladused/žetoonid (`token=***MASKED***`). Toetab `DEBUG_LOG_UNSANITIZED=true` lippu erakorraliseks silumiseks. |
| **[generate-local-certs.sh](generate-local-certs.sh)** | Genereerib kohaliku juur-CA ja SSL sertifikaadid (`config/certs/`) ning usaldab need macOS Keychainis, Windowsis või WSL-is. |

### 💻 5. Konteinerdatud veebi-ide initsialiseerimine
| Skript | Kirjeldus |
| :--- | :--- |
| **[init-web-ide.sh](init-web-ide.sh)** | Eelseadistab code-server seaded, SEPS Wallet sünkroonimise ja SQL Developer ühendused veebi-IDE sees (`web-ide`). |
| **[install-web-ide-extensions.sh](install-web-ide-extensions.sh)** | Paigaldab vajalikud ja kohandatud VS Code laiendused (VSIX) veebi-IDE sees. |

### ⚡ 6. Orkestreerimine ja tuuma optimeerimise Tööriistad
| Skript | Kirjeldus |
| :--- | :--- |
| **[common.sh](common.sh)** | Keskne jagatud tuumikteek (värvid, kestuse vormindus, progressi kuvamine, signaalide trap-puhastus ja pigz pakkimine). |
| **[generate-compose-override.sh](generate-compose-override.sh)** | Dünaamiline Podman Compose override generaator (`podman-compose.override.yml`) aktiivsete profiilide ja saladuste põhjal. |
| **[wait-db-healthy.sh](wait-db-healthy.sh)** | 2-etapiline kohanduv tervisekontrolli mootor, mis kontrollib konteineri tervist, TCP kuulajaid ja PDB READ WRITE olekut. |
| **[generate-setup-report.sh](generate-setup-report.sh)** | Mõõdikute ja paigaldusraportite generaator (JSON benchmarkid, ENV mõõdikud ja blueprintide Markdown audit). |
