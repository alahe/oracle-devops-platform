# [TASK-001]: Konteineriseeritud Arendusvahendid (Web IDE: VS Code + SQLcl + Git)

**Staatus:** `DONE`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Tooling`  
**Seotud Blueprintid:** `.env.9-*`, `.env.11-*`, `.env.12-*`, `.env.13-*`  
**Dokumentatsioon:** [docs/web-ide-artifactory.md](../../docs/web-ide-artifactory.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Arendajate masinates puuduvad sageli vajalikud Java versioonid (OpenJDK 21), SQLcl tööriistad või tekivad konfliktid lokaalsete versioonidega. Eesmärk oli pakkuda täielikult konteineriseeritud Zero-Install veebipõhist arenduskeskkonda.

## 2. Eesmärk ja Oodatav Tulemus
Brauseri kaudu ligipääsetav VS Code veebikeskkond (port 8090/8449), kus on eelpaigaldatud OpenJDK 21, Oracle SQLcl, Liquibase, Git, Python3, GitHub CLI (`gh`), `act` CLI ja ametlik Oracle SQL Developer laiendus.

## 3. Tehniline Teostus
- Loodud Dockerfile ja compose konfiguratsioon konteinerile `web-ide`.
- Skriptid `scripts/internal/init-web-ide.sh` ja `scripts/internal/install-web-ide-extensions.sh`.
- Integratsioon Podman võrgu ja jagatud töökaustaga `/workspace`.

## 4. Verifitseerimine
- Kontrollitud `web-ide` käivitumist ja laienduste laadimist pordil `8090`.
- Ühendus andmebaasiga läbi pre-installeeritud SQLcl utiliidi.
