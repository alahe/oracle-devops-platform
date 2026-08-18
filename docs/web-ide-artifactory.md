# Konteineriseeritud Web IDE & Enterprise Artifactory Peegeldusregister

See juhend kirjeldab **Konteineriseeritud Web IDE (`web-ide`)** seadistamist ja kasutamist brauseris ning selle integreerimist ettevõtte sisese **Artifactory Mirror Registry** (Docker peegeldusregister) registritega.

---

## 1. Web IDE Arhitektuur

Web IDE koondab täieliku Oracle ja CI/CD arenduskeskkonna ühte brauseripõhisesse VS Code liidesesse (`code-server`):
- **Brauseri URL:** `http://localhost:8090` (HTTP) või `https://localhost:8449` (HTTPS).
- **Pre-installeeritud tööriistad:** OpenJDK 21, Oracle SQLcl, Liquibase, Git, Python3, GitHub CLI (`gh`), `act` CLI.
- **VS Code laiendused:** `Oracle.sql-developer-for-vscode` ja `github.vscode-github-actions`.
- **SEPS Wallet & Ühendused:** Automaatselt ühendatud ja registreeritud konteineri sisse (`/config/.oracle/tns_admin`).

---

## 2. Ettevõtte Artifactory Registri Seadistamine (.env)

Selleks, et kasutada ettevõtte sisest Artifactory registrit avalike Docker Hub või GitHub registrite asemel (Rule 4), seadista failis `.env`:

```bash
# Sisse/välja lülitamine:
WEB_IDE_ENABLED=true

# Ettevõtte Artifactory peegeldusregistri aadress:
ARTIFACTORY_DOCKER_REGISTRY=artifactory.corp.internal

# Suuna Web IDE konteineri pilt Artifactory peegeldusse:
WEB_IDE_CONTAINER_IMAGE=artifactory.corp.internal/docker-remote/linuxserver/code-server:latest

# Määratud pordid:
WEB_IDE_HTTP_PORT=8090
WEB_IDE_HTTPS_PORT=8449
CICD_WEB_UI_PORT=8091
```

---

## 4. Google Antigravity Eraldiseisev Paigaldamine & VSIX Laiendused

### 🤖 Google Antigravity Paigaldus
Google Antigravity on eraldiseisev tehisintellekti koodiassistent (Standalone Agent), mida ei paigaldata tavalise VS Code laiendusena:
1. Google Antigravity paigaldatakse automaatselt otse Web IDE konteineri sisse (`https://antigravity.google/`).
2. Arendaja saab seda käivitada Web IDE brauseripõhisest terminalist käsuga `antigravity`.

### 📦 Kohalikud VS Code (.vsix) Laiendused
Tavaliste VS Code `.vsix` laienduste paigaldamiseks:
1. Aseta `.vsix` fail kausta **`binaries/extensions/`**.
2. Käivita paigaldus või taaskäivita konteinerid:
   ```bash
   ./scripts/start-containers.sh
   ```
3. Skript `scripts/internal/init-web-ide.sh` tuvastab kaustas olevad `.vsix` paketid ja paigaldab need automaatselt.



```bash
# 1. Käivita kogu keskkond koos Web IDE-ga:
./scripts/setup-all.sh

# 2. Käivita olemasolevad konteinerid koos Web IDE-ga:
./scripts/start-containers.sh

# 3. Käivita ilma Web IDE-ta (kui mälu on piiratud):
./scripts/setup-all.sh --no-web-ide
./scripts/start-containers.sh --no-web-ide

# 4. Puhasta Web IDE konteiner ja persistentne volume:
./scripts/reset-all.sh all
```
