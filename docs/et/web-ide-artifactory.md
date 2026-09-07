[ 🇬🇧 English ](../web-ide-artifactory.md) | [ 🇪🇪 Eesti ](web-ide-artifactory.md) | [ 🇫🇮 Suomi ](../fi/web-ide-artifactory.md) | [ 🇸🇪 Svenska ](../sv/web-ide-artifactory.md) | [ 🇱🇻 Latviešu ](../lv/web-ide-artifactory.md) | [ 🇱🇹 Lietuvių ](../lt/web-ide-artifactory.md)

# Konteineriseeritud Web IDE & Ettevõtte Laienduste Turg

See juhend kirjeldab **Konteineriseeritud Web IDE (`web-ide` / `code-server`)** seadistamist ja kasutamist brauseris, selle integreerimist ettevõtte sisese **Artifactory / VS Code Marketplace** turuga, **Oracle SQL Developer, Google Antigravity ja Microsoft Python** laiendusi ning **GitHub Actions töövoogude lokaalset ja turvalist võrguvaba (offline) testimist**.

---

## 1. Web IDE Arhitektuur & Eelpaigaldatud Tööriistad

Web IDE koondab täieliku Oracle, AI ja CI/CD arenduskeskkonna ühte brauseripõhisesse VS Code liidesesse (`localhost/oracle-web-ide:latest`):
- **Brauseri URL:** `http://localhost:8090` (HTTP) või `https://localhost:8449` (HTTPS).
- **Pre-installeeritud süsteemitööriistad:** OpenJDK 21, Oracle SQLcl 26.2, Liquibase, Git, Python3 (`venv`, `pytest`), GitHub CLI (`gh`), Nektos `act` CLI runner, `actionlint` ja `yamllint`.
- **Eelküpsetatud VS Code Laiendused:**
  1. 🗄️ **Oracle SQL Developer for VS Code** (`Oracle.sql-developer-for-vscode`, tootja: Oracle): Andmebaasipuu, SQL töölehed, PL/SQL redaktor, Explain Plan.
  2. 🤖 **Google Antigravity** (`google.antigravity`, tootja: Google): AI assistent, koodi refaktoorimine, paarisprogrammeerimine ja agentic töövood.
  3. 🐍 **Python Suite** (`ms-python.python`, `ms-python.vscode-pylance`, `ms-python.debugpy`, tootja: Microsoft): Python keeleserver, silur (debugger), virtuaalkeskkonnad (`venv`) ja `pytest` tugi.
  4. ⚙️ **GitHub Actions** (`github.vscode-github-actions`, tootja: GitHub): CI/CD töövoogude süntaks ja visuaalne haldus.
  5. 📄 **Red Hat YAML** (`redhat.vscode-yaml`, tootja: Red Hat): YAML profiilide ja compose failide skeemikontroll.
- **Automaatne `.sql` Failide Sidumine:**
  - Klikkides mistahes `.sql`, `.pls`, `.pks` või `.pkb` failile failipuus, avatakse see automaatselt otse **Oracle SQL Developer Redaktoris / SQL Töölehel** koos andmebaasiühenduse valikuga.
- **Kasutaja Arvuti Ühenduste Reaalajas Sünkroonimine:**
  - Host-arvuti kataloog `$HOME/.dbtools/connections` mounteeritakse kausta `/config/.dbtools/connections:rw`.
  - SEPS Wallet (`config/tns_admin_container`) mounteeritakse kausta `/config/.oracle/tns_admin:ro`.
  - Kõik host-masinas loodud ühendused (`DB_PROXY_DEV`, `DB_ALISE_DEV` jne) on Web IDE-s koheselt nähtavad ja paroolivabalt kasutatavad.

---

## 2. 4-Tasemeline Laienduste Lahendamine & Puhver (`binaries/extensions/`)

Web IDE käivitumisel lahendatakse laiendused järgmises järjekorras:
```
1. 📁 binaries/extensions/*.vsix         ➔ Lokaalne Air-Gapped puhver (Kõrgeim prioriteet, 0 võrgupäringut)
2. 📁 $HOME/.vscode/extensions/          ➔ Töölaua VS Code laienduste automaatne sünkroonimine
3. 🌐 download_url profiili YAML-is      ➔ Allalaadimine ja puhverdamine kausta binaries/extensions/
4. 🌐 code-server --install-extension    ➔ Seadistatud turg (Open VSX või Microsoft Marketplace)
```

### Turupakkuja Valik (`.env`):
Saad määrata laienduste turu failis `.env`:
```bash
# Valikud: openvsx (vaikimisi) | microsoft | artifactory
VSCODE_MARKETPLACE_PROVIDER=microsoft
```

---

## 3. GitHub Actions Töövoogude Täielik Võrguvaba Testimine (`act` ja `actionlint`)

Web IDE võimaldab testida ja siluda repositooriumi GitHub Actions töövooge (`.github/workflows/*.yml`) **100% lokaalselt ilma GitHubi ühenduseta ja ilma koodi/saladuste üleslaadimiseta**:

### 💻 Kasulikud käsud Web IDE terminalis:
1. **Staatiline turva- ja süntaksianalüüs (actionlint):**
   ```bash
   actionlint
   ```
2. **Loetle kõik töövood ja sammud:**
   ```bash
   act -l
   ```
3. **Käivita lokaalne CI kuivkäivitus:**
   ```bash
   ./scripts/test-local-ci.sh --dry-run
   ```
4. **Käivita isoleeritud lokaalsete saladustega:**
   ```bash
   act push --secret-file .env.secrets
   ```

---

## 4. Ettevõtte Artifactory Registri Seadistamine (.env)

Selleks, et kasutada ettevõtte sisest Artifactory registrit avalike registrite asemel (Reegel 4), seadista failis `.env`:
```bash
ARTIFACTORY_DOCKER_REGISTRY=artifactory.company.local:5000
VSCODE_MARKETPLACE_PROVIDER=artifactory
```

---

## 4. Kohalikud VS Code (.vsix) Laiendused ja Uuendused (UI Update)

1. **Laienduste uuendamine veebiliideses:**
   - Web IDE veebiliideses ("Extensions" vahekaart) saab arendaja teha igal ajal vabalt "Update" või otsida Marketplace'ist uusi laiendusi. Need salvestuvad püsivasse `/config` kettamahtu.
2. **Kohalike .vsix failide offline paigaldamine:**
   - Aseta `.vsix` fail kausta **`binaries/extensions/`**.
   - Käivitamisel tuvastab `scripts/internal/init-web-ide.sh` failid ja paigaldab need automaatselt.

---

## 5. Web IDE Elutsükli Käsud

```bash
# 1. Käivita Blueprint koos Web IDE-ga (nt Blueprint 30):
./scripts/setup-all.sh -b 30

# 2. Käivita olemasolevad konteinerid koos Web IDE-ga:
./scripts/start-containers.sh

# 3. Ehita / uuenda Web IDE konteineripilt lokaalselt:
./docker/web-ide/build-web-ide-image.sh

# 4. Käivita ilma Web IDE-ta (kui mälu on piiratud):
./scripts/setup-all.sh --no-web-ide
./scripts/start-containers.sh --no-web-ide

# 5. Puhasta Web IDE konteiner ja persistentne volume:
./scripts/reset-all.sh all
```