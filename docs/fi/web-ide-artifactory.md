[ 🇬🇧 English ](../web-ide-artifactory.md) | [ 🇪🇪 Eesti ](../et/web-ide-artifactory.md) | [ 🇫🇮 Suomi ](web-ide-artifactory.md) | [ 🇸🇪 Svenska ](../sv/web-ide-artifactory.md) | [ 🇱🇻 Latviešu ](../lv/web-ide-artifactory.md) | [ 🇱🇹 Lietuvių ](../lt/web-ide-artifactory.md)

# Konttipohjainen Web IDE & Yrityksen Laajennusmarkkinapaikka

Tämä ohje kuvaa **konttipohjaisen Web IDE:n (`web-ide` / `code-server`)** määritystä ja käyttöä selaimessa, integrointia yrityksen sisäiseen **Artifactory / VS Code Marketplace** -rekisteriin, **Oracle SQL Developer, Google Antigravity ja Microsoft Python** -laajennuksia sekä **GitHub Actions -työnkulkujen paikallista ja turvallista verkkotonta (offline) testausta**.

---

## 1. Web IDE -Arkkitehtuuri & Esiasennetut Työkalut

Web IDE kokoaa täydellisen Oracle-, tekoäly- ja CI/CD-kehitysympäristön yhteen selainpohjaiseen VS Code -liittymään (`localhost/oracle-web-ide:latest`):
- **Selaimen URL:** `http://localhost:8090` (HTTP) tai `https://localhost:8449` (HTTPS).
- **Esiasennetut järjestelmätyökalut:** OpenJDK 21, Oracle SQLcl 26.2, Liquibase, Git, Python3 (`venv`, `pytest`), GitHub CLI (`gh`), Nektos `act` CLI runner, `actionlint` ja `yamllint`.
- **Esiasennetut VS Code -laajennukset:**
  1. 🗄️ **Oracle SQL Developer for VS Code** (`Oracle.sql-developer-for-vscode`, toimittaja: Oracle): Tietokantapuu, SQL-työarkit, PL/SQL-editori, Explain Plan.
  2. 🤖 **Google Antigravity** (`google.antigravity`, toimittaja: Google): Tekoälyavustaja, koodin refaktorointi ja agenttityönkulut.
  3. 🐍 **Python Suite** (`ms-python.python`, `ms-python.vscode-pylance`, `ms-python.debugpy`, toimittaja: Microsoft): Python-kielipalvelin, debuggeri, virtuaaliympäristöt (`venv`) ja `pytest`.
  4. ⚙️ **GitHub Actions** (`github.vscode-github-actions`, toimittaja: GitHub): CI/CD-työnkulkujen syntaksi ja visuaalinen hallinta.
  5. 📄 **Red Hat YAML** (`redhat.vscode-yaml`, toimittaja: Red Hat): YAML-profiilien ja compose-tiedostojen validointi.
- **Automaattinen `.sql` Tiedostokytkentä:**
  - Kaikki `.sql`, `.pls`, `.pks` ja `.pkb` tiedostot avautuvat suoraan **Oracle SQL Developer -editoriin / SQL-työarkille** tietokantayhteyden kera.
- **Isäntäkoneen Yhteyksien Reaaliaikainen Synkronointi:**
  - Isäntäkoneen hakemisto `$HOME/.dbtools/connections` liitetään polkuun `/config/.dbtools/connections:rw`.
  - SEPS Wallet (`config/tns_admin_container`) liitetään polkuun `/config/.oracle/tns_admin:ro`.
  - Kaikki isännässä luodut yhteydet (`DB_PROXY_DEV`, `DB_ALISE_DEV` jne.) ovat Web IDE:ssä välittömästi näkyvissä ja salasanattomasti käytettävissä.

---

## 2. 4-Tasoinen Laajennusten Ratkaisujärjestys & Välimuisti (`binaries/extensions/`)

```
1. 📁 binaries/extensions/*.vsix         ➔ Paikallinen Air-Gapped välimuisti (Korkein prioriteetti, 0 verkkopyyntöä)
2. 📁 $HOME/.vscode/extensions/          ➔ Työpöytä-VS Code -laajennusten automaattinen synkronointi
3. 🌐 download_url profiilissa           ➔ Lataus ja tallennus hakemistoon binaries/extensions/
4. 🌐 code-server --install-extension    ➔ Määritetty markkinapaikka (Open VSX tai Microsoft Marketplace)
```

### Markkinapaikkavalitsin (`.env`):
```bash
# Vaihtoehdot: openvsx (oletus) | microsoft | artifactory
VSCODE_MARKETPLACE_PROVIDER=microsoft
```

---

## 3. GitHub Actions -Työnkulkujen Verkkoton Testaus (`act` ja `actionlint`)

```bash
# 1. Staattinen tietoturva- ja syntaksitarkistus
actionlint

# 2. Työnkulkujen listaaminen
act -l

# 3. Paikallinen kuiva-ajo
./scripts/test-local-ci.sh --dry-run
```

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
