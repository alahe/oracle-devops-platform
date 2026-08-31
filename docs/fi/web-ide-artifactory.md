[ 🇬🇧 English ](../web-ide-artifactory.md) | [ 🇪🇪 Eesti ](../et/web-ide-artifactory.md) | [ 🇫🇮 Suomi ](web-ide-artifactory.md) | [ 🇸🇪 Svenska ](../sv/README.md) | [ 🇱🇻 Latviešu ](../lv/README.md) | [ 🇱🇹 Lietuvių ](../lt/README.md)

# Konttipohjainen Web IDE & Yrityksen Artifactory -Peilirekisteri

Tämä ohje kuvaa **konttipohjaisen Web IDE:n (`web-ide` / `code-server`)** määritystä ja käyttöä selaimessa, integrointia yrityksen sisäiseen **Artifactory Mirror Registry** -rekisteriin sekä **GitHub Actions -työnkulkujen paikallista ja täysin verkotonta (offline) testausta**.

---

## 1. Web IDE -Arkkitehtuuri & Esiasennetut Työkalut

Web IDE kokoaa täydellisen Oracle-, tekoäly- ja CI/CD-kehitysympäristön yhteen selainpohjaiseen VS Code -liittymään (`localhost/oracle-web-ide:latest`):
- **Selaimen URL:** `http://localhost:8090` (HTTP) tai `https://localhost:8449` (HTTPS).
- **Esiasennetut järjestelmätyökalut:** OpenJDK 21, Oracle SQLcl 26.2, Liquibase, Git, Python3, GitHub CLI (`gh`), Nektos `act` CLI runner.
- **Esiasennetut VS Code -laajennukset:**
  1. 🗄️ **Oracle SQL Developer for VS Code** (`Oracle.sql-developer-for-vscode`): Tietokantapuu, SQL-työarkit, PL/SQL-editori, Explain Plan.
  2. 🤖 **Google Antigravity for VS Code** (`google.antigravity`): Tekoälyavustaja, koodin refaktorointi ja agenttityönkulut.
  3. ⚙️ **GitHub Actions** (`github.vscode-github-actions`): CI/CD-työnkulkujen syntaksi ja visuaalinen hallinta.
  4. 📄 **Red Hat YAML** (`redhat.vscode-yaml`): YAML-profiilien ja compose-tiedostojen validointi.
- **Isäntäkoneen Yhteyksien Reaaliaikainen Synkronointi:**
  - Isäntäkoneen hakemisto `$HOME/.dbtools/connections` liitetään polkuun `/config/.dbtools/connections:rw`.
  - SEPS Wallet (`config/tns_admin_container`) liitetään polkuun `/config/.oracle/tns_admin:ro`.
  - Kaikki isännässä luodut yhteydet (`DB_PROXY_DEV`, `DB_ALISE_DEV` jne.) ovat Web IDE:ssä välittömästi näkyvissä ja salasanattomasti käytettävissä.

---

## 2. GitHub Actions -Työnkulkujen Verkkoton (Offline) Testaus (`act`)

Web IDE mahdollistaa arkiston GitHub Actions -työnkulkujen (`.github/workflows/*.yml`) testaamisen ja virheenkorjauksen **100% paikallisesti ilman GitHub-yhteyttä ja koodin lataamista pilveen**:

### 💻 Hyödyllisiä komentoja Web IDE -terminaalissa:

1. **Listaa kaikki työnkulut (Dry-Run):**
   ```bash
   act -l
   ```
2. **Suorita tietty työnkulkutiedosto:**
   ```bash
   act -W .github/workflows/local-ci.yml
   ```
3. **Simuloi `push`-tapahtumaa:**
   ```bash
   act push
   ```
