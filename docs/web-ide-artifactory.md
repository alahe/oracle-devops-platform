[ 🇬🇧 English ](web-ide-artifactory.md) | [ 🇪🇪 Eesti ](et/web-ide-artifactory.md) | [ 🇸🇪 Svenska ](sv/README.md) | [ 🇱🇻 Latviešu ](lv/README.md) | [ 🇱🇹 Lietuvių ](lt/README.md)

# Konteineriseeritud Web IDE & Enterprise Artifactory Peegeldusregister

See juhend kirjeldab **Konteineriseeritud Web IDE (`web-ide` / `code-server`)** seadistamist ja kasutamist brauseris, selle integreerimist ettevõtte sisese **Artifactory Mirror Registry** registritega ning **GitHub Actions töövoogude lokaalset ja täielikult võrguvaba (offline) testimist**.

---

## 1. Web IDE Arhitektuur & Eelpaigaldatud Tööriistad

Web IDE koondab täieliku Oracle, AI ja CI/CD arenduskeskkonna ühte brauseripõhisesse VS Code liidesesse (`localhost/oracle-web-ide:latest`):
- **Brauseri URL:** `http://localhost:8090` (HTTP) või `https://localhost:8449` (HTTPS).
- **Pre-installeeritud süsteemitööriistad:** OpenJDK 21, Oracle SQLcl 26.2, Liquibase, Git, Python3, GitHub CLI (`gh`), Nektos `act` CLI runner.
- **Eelküpsetatud VS Code Laiendused:**
  1. 🗄️ **Oracle SQL Developer for VS Code** (`Oracle.sql-developer-for-vscode`): Andmebaasipuu, SQL töölehed, PL/SQL redaktor, Explain Plan.
  2. 🤖 **Google Antigravity for VS Code** (`google.antigravity`): AI assistent, koodi refaktoorimine, paarisprogrammeerimine ja agentic töövood.
  3. ⚙️ **GitHub Actions** (`github.vscode-github-actions`): CI/CD töövoogude süntaks ja visuaalne haldus.
  4. 📄 **Red Hat YAML** (`redhat.vscode-yaml`): YAML profiilide ja compose failide skeemikontroll.
- **Kasutaja Arvuti Ühenduste Reaalajas Sünkroonimine:**
  - Host-arvuti kataloog `$HOME/.dbtools/connections` mounteeritakse kausta `/config/.dbtools/connections:rw`.
  - SEPS Wallet (`config/tns_admin_container`) mounteeritakse kausta `/config/.oracle/tns_admin:ro`.
  - Kõik host-masinas loodud ühendused (`DB_PROXY_DEV`, `DB_ALISE_DEV` jne) on Web IDE-s koheselt nähtavad ja paroolivabalt kasutatavad.

---

## 2. GitHub Actions Töövoogude Täielik Võrguvaba (Offline) Testimine (`act` ja `gh`)

Web IDE võimaldab testida ja siluda repositooriumi GitHub Actions töövooge (`.github/workflows/*.yml`) **100% lokaalselt ilma GitHubi ühenduseta ja ilma koodi üleslaadimiseta**:

### 🔍 Kuidas see töötab?
- **Ei vaja välist Git/GitHub ühendust:** Nektos `act` loeb töövooge otse Sinu lokaalselt kettalt (`/workspace/.github/workflows/`).
- **Käivitab sammud kohapeal:** Käivitab samad konteinerid, skriptid, SQL-päringud ja Liquibase migratsioonid täpselt samamoodi nagu GitHubi pilveserveris.
- **Turvaline saladuste testimine:** Töövoos nõutavad paroolid ja muutujad loetakse kohalikust failist ilma neid pilve laadimata.

### 💻 Kasulikud käsud Web IDE terminalis (`http://localhost:8090`):

1. **Loetle kõik töövood ja sammud (Dry-Run / ülevaade):**
   ```bash
   act -l
   ```

2. **Käivita konkreetne töövoo fail:**
   ```bash
   act -W .github/workflows/local-ci.yml
   ```

3. **Simuleeri `push` sündmust:**
   ```bash
   act push
   ```

4. **Käivita kohalike saladuste / paroolidega:**
   ```bash
   # Kasuta .env faili saladustena:
   act push --secret-file .env
   ```

5. **GitHub CLI (`gh`) staatuse kontroll:**
   ```bash
   gh workflow list
   ```

---

## 3. Ettevõtte Artifactory Registri Seadistamine (.env)

Selleks, et kasutada ettevõtte sisest Artifactory registrit avalike Docker Hub või GitHub registrite asemel (Rule 4), seadista failis `.env`:

```bash
# Web IDE teenuse profiilid (config/profiles/web-ide/*.yaml):
#   - web-ide-cicd-standard        (GitHub CLI + act runner GitHub Actions testimiseks)
#   - web-ide-artifactory-vsix     (VSIX laiendused lokaalsest kaustast)
#   - web-ide-standard             (Täielik VS Code + SQL Developer + Liquibase)
WEB_IDE_PROFILE=web-ide-standard

# Ettevõtte Artifactory peegeldusregistri aadress (valikuline):
ARTIFACTORY_DOCKER_REGISTRY=artifactory.corp.internal
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