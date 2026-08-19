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
# Web IDE teenuse profiilid (config/profiles/web-ide/*.yaml):
#   - web-ide-cicd-standard        (GitHub CLI + act runner GitHub Actions testimiseks)
#   - web-ide-artifactory-vsix     (VSIX laiendused lokaalsest kaustast)
#   - web-ide-standard             (Täielik VS Code + SQL Developer + Liquibase)
WEB_IDE_PROFILE=web-ide-standard

# Ettevõtte Artifactory peegeldusregistri aadress (valikuline):
ARTIFACTORY_DOCKER_REGISTRY=artifactory.corp.internal
```

---

## 3. GitHub Actions Töövoogude Lokaalne Testimine (`act` ja `gh`)

Web IDE konteiner võimaldab testida repositooriumi GitHub Actions töövooge (`.github/workflows/*.yml`) **lokaalselt ilma GitHubi pushimata**:

1. Vali `.env` failis profiil `WEB_IDE_PROFILE=web-ide-cicd-standard`.
2. Ava brauseri terminal aadressil `http://localhost:8090`.
3. Käivita lokaalne GitHub Actions simulaator:
   ```bash
   # Testi kõiki repositooriumi töövooge:
   act

   # Testi konkreetset sündmust (nt push):
   act push

   # Kontrolli GitHub CLI staatust:
   gh workflow list
   ```

---

## 4. Kohalikud VS Code (.vsix) Laiendused

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
