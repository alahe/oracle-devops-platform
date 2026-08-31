# [TASK-002]: GitHub Actions / CI/CD Töövoog & Lokaalne Offline Testimine

**Staatus:** `DONE`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Tooling`  
**Dokumentatsioon:** [docs/github-actions-cicd.md](../../docs/web-ide-artifactory.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Andmebaasi muudatuste ja skeemide tarnimine vajab automatiseeritud CI/CD pipeline'i, mida arendaja saab testida nii lokaalselt (offline) kui ka GitHub Actions pilves.

## 2. Eesmärk ja Oodatav Tulemus
SQLcl Projects põhine automaatne tarnimine (`project deploy`), lokaalne simulaator [`scripts/test-local-ci.sh`](../../scripts/test-local-ci.sh) ja ühilduvus Nektos `act` CLI-ga.

## 3. Tehniline Teostus
- Konfigureeritud `.dbtools/project.config.json` ja `.github/workflows/deploy-remote-cloud.yml`.
- Loodud `scripts/test-local-ci.sh` ja `scripts/internal/export-ci-secrets.sh`.

## 4. Verifitseerimine
- Testitud `test-local-ci.sh` käivitamist ja skeemiobjektide automaatset kompileerimist.
