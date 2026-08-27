# [TASK-020]: Oracle Cloud (OCI) Kaug-Paigalduse Katse ja Pilve-Tarne

**Staatus:** `TODO`  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `Orchestration`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Kogu keskkonna toimivust on vaja reaalselt katsetada ja verifitseerida OCI Always Free ARM/x86 VM-is.

## 2. Eesmärk ja Oodatav Tulemus
Automaatne kaug-paigaldus käsuga `./scripts/deploy-remote.sh` ning GitHub Actions workflow käivitus reaalses pilvekeskkonnas.

## 3. Tehniline Teostus
- Skript [`scripts/deploy-remote.sh`](../../scripts/deploy-remote.sh).
- GitHub Actions workflow `.github/workflows/deploy-remote-cloud.yml`.

## 4. Verifitseerimine
- Pilvepõhine tervisekontroll ja testiraporti genereerimine.
