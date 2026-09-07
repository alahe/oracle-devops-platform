[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# ⚙️ Sisäisten Komentosarjojen Hakemisto (`scripts/internal/`)

Säännön **Rule 3 (Directory Layout Rule for Scripts)** mukaisesti tämä hakemisto sisältää automaatiomoottoreita, profiilinjäsentimiä, tietokannan alustajia, automatisoituja asennusvaiheita ja SQL-tiedostoja, joita ympäristön orkestroija (`setup-all.sh`) käyttää sisäisesti.

> 💡 **Kehittäjätyökalut:** Päivittäiset CLI-työkalut (`get-password.sh`, `check-urls.sh`, `check-wallet.sh`, `create-developer.sh`, `register-connections.sh`) sijaitsevat suoraan hakemistossa [`scripts/`](../README.fi.md).

---

## 📂 Sisäisten Komentosarjojen Viitteet

### 📦 1. Profiilimoottori ja Topologian Hallinta
| Komentosarja | Kuvaus |
| :--- | :--- |
| **[load-profile.sh](load-profile.sh)** | Dynaaminen YAML-profiilinjäsennin (`config/profiles/*/*.yaml`). Soveltaa 3-tasoista prioriteettihierarkiaa säilökuville ja ZIP-URL-osoitteille. |
| **[resolve-topology.sh](resolve-topology.sh)** | Moni-ilmentymäinen topologian hallitsija (`config/topology.yaml`). Määrittää törmäämättömät portit (`1532`, `1533`, `8443`, `8444`). |
| **[apply-profile-users.sh](apply-profile-users.sh)** | Dynaaminen DB-käyttäjien hallinta, roolien määritys (`DB_DEVELOPER_ROLE`, `CONSOLE_DEVELOPER`), ORDS REST -kartoitus ja APEX-työtilakäyttäjät. |

### 🚀 2. APEX- ja ORDS-Moottorin Asennus
| Komentosarja | Kuvaus |
| :--- | :--- |
| **[install-apex.sh](install-apex.sh)** | Automatisoitu APEX-moottorin asennus (`@apexins.sql`) Oracle Free DB 23ai -ilmentymiin. |
| **[install-ords-standalone.sh](install-ords-standalone.sh)** | Erillinen ORDS-asennuskomentosarja Linux-palvelinasennuksille ilman Dockeria. |
| **[deploy-apex-apps.sh](deploy-apex-apps.sh)** | Peräkkäinen APEX-sovellusten tuoja hakemiston `binaries/apex_apps/` tiedostoille. |
| **[deploy-apex.sql](deploy-apex.sql)** | SQLcl PL/SQL -kääre APEX-sovellusten SQL-viennin tuomiseen. |

### 🔌 3. Profiiliohjattu Ilmentymän Alustus
| Komentosarja / SQL | Kuvaus |
| :--- | :--- |
| **[init-db-instance.sh](init-db-instance.sh)** | Yleinen profiiliohjattu tietokannan alustuskomentosarja mille tahansa profiilille (`proxy`, `appinfra`, `bizapp`, `cicd`). |
| **[init-db-instance.sql](init-db-instance.sql)** | Profiiliohjattu PL/SQL-komentosarja, joka määrittää muistiparametrit, taulutilat ja REST-verkon ACL-säännöt. |

### 🔑 4. Tietoturva, Salaisuudet ja Sertifikaatit
| Komentosarja | Kuvaus |
| :--- | :--- |
| **[create-wallet.sh](create-wallet.sh)** | Luo Oracle SEPS (Secure External Password Store) -automaattikirjautumislompakot (`cwallet.sso`). |
| **[export-ci-secrets.sh](export-ci-secrets.sh)** | Pakkaa paikallisen SEPS Walletin Base64-koodatuksi merkkijonoksi (`DB_WALLET_BASE64`) GitHub Secrets- ja CI/CD-putkia varten. |
| **[generate-passwords.sh](generate-passwords.sh)** | Luo satunnaisia vahvoja salasanoja ja rekisteröi ne Podman Secrets -salaisuuksiksi. |
| **[sanitize-logs.sh](sanitize-logs.sh)** | Virtasuodatin stdout/stderr-lokeille; peittää salaisuudet/tunnukset (`token=***MASKED***`). Tukee `DEBUG_LOG_UNSANITIZED=true` -ohitusta hätätilannevirheenkorjaukseen. |
| **[generate-local-certs.sh](generate-local-certs.sh)** | Luo paikallisen juuri-CA:n ja SSL-sertifikaatit (`config/certs/`) ja asentaa luottamuksen macOS-, Windows- tai WSL-järjestelmissä. |

### 💻 5. Säilöidyn Verkko-IDE:n Alustus
| Komentosarja | Kuvaus |
| :--- | :--- |
| **[init-web-ide.sh](init-web-ide.sh)** | Esikonfiguroi code-server-asetukset, SEPS Wallet -synkronoinnin ja SQL Developer -yhteydet verkko-IDE:n sisällä (`web-ide`). |
| **[install-web-ide-extensions.sh](install-web-ide-extensions.sh)** | Asentaa tarvittavat ja mukautetut VS Code -laajennukset (VSIX) verkko-IDE:n sisälle. |

### ⚡ 6. Orkestrointi- ja Ydintoiminnot
| Komentosarja | Kuvaus |
| :--- | :--- |
| **[common.sh](common.sh)** | Keskeinen jaettu ysinkirjasto (värit, keston muotoilu, edistymisen raportointi, signaalipuhdistus ja pigz-pakkaus). |
| **[generate-compose-override.sh](generate-compose-override.sh)** | Dynaaminen Podman Compose override -generaattori (`podman-compose.override.yml`) aktiivisten profiilien pohjalta. |
| **[wait-db-healthy.sh](wait-db-healthy.sh)** | 2-vaiheinen mukautuva terveystarkistusmoottori, joka tarkistaa säilön terveyden, TCP-kuuntelijat ja PDB READ WRITE -tilan. |
| **[generate-setup-report.sh](generate-setup-report.sh)** | Mittareiden ja asennusraporttien generaattori (JSON-suorituskykymittaukset, ENV-arvot ja arkkitehtuuriraportit). |
