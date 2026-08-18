# Arenduskeskkonna Laiendamise Analüüs

See dokument analüüsib arendaja poolt märkmetes välja toodud kolme ettepanekut lokaalse arenduskeskkonna ja CI/CD võimekuste laiendamiseks range korporatiivse turvapoliitikaga keskkondades.

---

## 1. Konteineriseeritud Arendusvahendid (VS Code + SQL Developer + Git jne)

**Staatuse Uuendus:** ✅ **REALISEERITUD JA VALIDEERITUD**
Detailne kasutusjuhend asub failis: 📄 **[docs/web-ide-artifactory.md](web-ide-artifactory.md)**.

Arendaja lokaalsesse masinasse Java, SQL Developer for VS Code või muude kohalike tööriistade paigaldamise piirangute ületamiseks on käivitatav **veebipõhine IDE konteiner (Web IDE Container)**.

### Tehniline teostus & Artifactory tugi
*   Baseerub `code-server` Linux-põhisel konteineri pildil (toetab ettevõtte Artifactory peegeldust `ARTIFACTORY_DOCKER_REGISTRY`).
*   Pildile on pre-installeeritud: OpenJDK 21, Oracle SQLcl, Liquibase, Git, Python3, GitHub CLI (`gh`), `act` CLI ja VS Code laiendused `Oracle.sql-developer-for-vscode` ja `github.vscode-github-actions`.
*   Arendaja kohalik koodikaust, `.env` fail ning `config/tns_admin_container` kataloog mountitakse konteineri sisse.
*   Arendaja avab kohalikust arvutist brauseri aadressil `http://localhost:8090` ja töötab täisfunktsionaalses VS Code keskkonnas.


| **Isoleeritud turvalisus:** Tööriistad on piiratud ainult konteineri ja määratud võrguga. | **Töölaua integreeritus:** Failide lohistamine kohalikult töölaualt otse konteinerisse vajab brauseri kaudu tegemist. |

### Antigravity kasutamine konteineris
*   **Teostatavus:** 100% teostatav. Kuna veebipõhine IDE toetab standardseid VS Code laiendusi, saab Antigravity arendusabilise `.vsix` paketina või otse laienduste kataloogist sinna installeerida.
*   **API ligipääs:** Laiendus saab ilma probleemideta teha päringuid Gemini/Google Cloud API-le, kuna konteiner kasutab host-arvuti võrku ja internetiühendust.

---

## 2. GitHub Actions / CI/CD Töövoog & Lokaalne Offline Testimine Podmanis

**Staatuse Uuendus:** ✅ **REALISEERITUD JA VALIDEERITUD**
Detailne kasutusjuhend asub failis: 📄 **[docs/github-actions-cicd.md](github-actions-cicd.md)**.

### Tehniline teostus & Lokaalse testimise variandid

Et arendaja saaks GitHub Action töövoogusid testida oma masinas ja sisevõrgus täielikult **offline režiimis** (SQLcl Projects põhil) ilma GitHubi serveritesse koodi pushimata, lisasime keskkonda järgmised komponendid:

1. **SQLcl Projects (`.dbtools/project.config.json` & `.dbtools/filters/project.filters`):**
   * Automatiseeritud skeemimuudatuste ja paketiautomaatika haldus (`project stage`, `project deploy`).

2. **Lokaalne Offline Simulaator (`./scripts/test-local-ci.sh`):**
   * Käivitab `.github/workflows/deploy-apex.yml` töövoo lokaalselt Podmanis, genereerides SEPS Walletist automaatselt `.env.secrets` faili.


1. **`act` (Nektos `act`) CLI tööriist:**
   * Käivitab `.github/workflows/*.yml` töövood otse kohalikus Podman konteineris.
   * **Offline võimekus:** Kui runneri pilt (`catthehacker/ubuntu:act-latest` või `node:20-slim`) ja tegevused on ketsitud, töötab `act` täielikult ilma internetiühenduseta.
   * Integratsioon `.env.secrets` failiga imiteerib GitHub Secrets väärtusi (SEPS Wallet, andmebaasi paroolid) lokaalselt.

2. **GitHub CLI (`gh` CLI):**
   * Võimaldab lokaalselt syntaksit kontrollida, töövoogusid päästikustada ja tulemusi simuleerida.

3. **VS Code GitHub Actions Visuaalne UI Laiendus (`github.vscode-github-actions`):**
   * Pre-installeeritakse `web-ide` konteinerisse. Kuvab VS Code külgribal visuaalse puuvaate töövoogudest, sammudest, staatusest ja võimaldab lokaalseid päästikustamisi hiireklõpsuga.

4. **Web UI Liides / Armatuurlaud (`act-ui` & Lokaalne HTML Aruandlus):**
   * **`act-ui` (Brauseripõhine Dashboard):** Veebipõhine liides (port `8091`), mis kuvab brauseris reaalajas töövoogude käivitamist, visuaalset sammude graafi (DAG) ja logisid nagu päris GitHub.com keskkonnas.
   * **Interaktiivne TUI (Terminal UI):** Käsk `act -i` võimaldab käsureal valida visuaalse menüü kaudu, millist sündmust või workflow-d käivitada.

5. **Kohalik CI/CD Imiteerimisskript (`./scripts/test-local-ci.sh`):**
   * Käivitab GitHub Action sammud (Liquibase `lb update`, APEX import/export) meie ajutiste konteinerite (ephemeral container fallback) abil otse ilma täiendava runneri koormuseta.


### Mida peame `web-ide` konteinerisse lisama (Konteineri paketid):
*   `act` binaarfail (`/usr/local/bin/act`)
*   `gh` (GitHub CLI) paketid
*   VS Code laiendus `github.vscode-github-actions`
*   Podman socketi mount (`/run/user/1000/podman/podman.sock` -> `/var/run/docker.sock`), et `act` saaks käivitada töövoolu samme konteineri sees.

### Plussid ja miinused
| Plussid | Miinused |
| :--- | :--- |
| **Kiire tagasiside ja Offline töö:** Arendaja saab testida tarneskripte ja migratsioone ilma koodi pushimata ja ilma internetita. | **Podman-in-Podman ressursikulu:** `act`-i kasutamine konteineri sees vajab Podman socketi jagamist või ketsitud runneri pilti (~200MB). |
| **Täielik automatiseeritus:** Kaovad ära manuaalsed sammud andmebaasis. Iga koodimuudatus viiakse serverisse sekunditega. | **Sisevõrgu piirangud (VPN):** Avalikud GitHub runnerid vajavad sisevõrgu andmebaasidele ligipääsuks Self-Hosted Runnerit. |

---

## 3. Oracle Analytics Publisher (Pixel Perfect) Kohalik Käivitamine

Analytics Publisheri (endise nimega BI Publisher / XML Publisher) kohalikuks testimiseks mõeldud konteiner ja haldusskriptid.

### Tehniline teostus
*   Kuna Oracle ei jaga Analytics Publisherist valmis avalikku Docker pilti, kasutatakse ehitamiseks [oracle/docker-images](https://github.com/oracle/docker-images) malle.
*   Arendaja peab ühekorraselt alla laadima WebLogic ja OAS/Publisher binaries (ZIP), asetama need kausta ja käivitama ehitusskripti.
*   Konteiner ühendub stardil meie olemasoleva `db-publisher` andmebaasiga (mis initsialiseeritakse RCU tööriista abil).
*   Kasutajaliides on kättesaadav aadressil `http://localhost:9502/xmlpserver`.

### Plussid ja miinused
| Plussid | Miinused |
| :--- | :--- |
| **Lokaalne raportite disainimine:** Arendaja saab luua, testida ja muuta Pixel Perfect raporteid otse oma arvutis ilma ühise serveri koormamiseta. | **Äärmiselt suur ressursikulu:** OAS/Publisher konteiner vajab stabiilseks tööks **vähemalt 4 GB (soovitavalt 8 GB) vaba RAM-i**. |
| **Offline ja VPN-vaba töö:** Võimalik töötada ja testida ilma võrguühenduseta ja täiesti sisevõrgu väliselt. | **Keeruline ehitus ja pikad stardiajad:** Pildi ehitamine võtab ca 20-30 minutit ja konteineri käivitumine ca 3-5 minutit. |

---

## 4. VS Code Ühenduste Universaalne Registreerimine (ADB + Standard režiim)

**Staatus:** Teostatud & Valideeritud ✅

### Kirjeldus & Teostus
*   **Kaustad:** `/APEX` (Standard DB režiimis), `/MYATP` (ADB režiimis), `/Publisher` (Publisher DB puhul).
*   **Automaatne registreerimine:** Käivitub automaatselt skripti `setup-all.sh` lõpus lokaalses režiimis.

---

## 5. Ristplatvormne SSL Juursertifikaadi Automaatne Kontroll & Usaldamine (macOS + Windows + WSL)

**Staatus:** Teostatud & Valideeritud ✅

### Kirjeldus
Kui `setup-all.sh` töötab, kontrollib ja usaldab see automaatselt HTTPS juursertifikaadi (`config/certs/localCA.pem`) operatsioonisüsteemi sertifikaadihoidlas:
*   **Windows (Git Bash & MSYS):** Käivitatakse automaatselt `certutil -addstore -f -user Root`, mis lisab sertifikaadi aktiivse kasutaja hoidlasse **ilma administraatori õigusteta ja 0 parooliküsimusega**.
*   **WSL (Windows Subsystem for Linux):** Käivitatakse `certutil.exe -addstore -f -user Root $(wslpath -w config/certs/localCA.pem)`, mis usaldab sertifikaadi samuti automaatselt Windowsi poolel.
*   **macOS:** Kontrollitakse süsteemset võtmehoidjat (`security find-certificate`) ning pakutakse mugavat viipa `sudo security add-trusted-cert`.
*   **Pordi automaatne tuvastus:** Tuvastatakse automaatselt õige HTTPS port (ADB režiimis `8443`, Standard režiimis `8448`).

---

## 6. Dünaamiline YAML Andmebaasi Profiilide Mootor & Topoloogia Haldur

**Staatus:** Teostatud & Valideeritud ✅

### Kirjeldus & Arhitektuur
*   **Profiilide Maatriks (`config/profiles/*.yaml`):** Luua 7 standardset profiili, mis koondavad inimmõistetava kirjeldusvälja (`description`), pilditarnija (`oracle`/`gvenzl`), DB tüübi (`adb`/`standard`), kasutusotstarbe (`proxy`, `bizapp`, `appinfra`, `cicd`) ja moodulsed komponendid (`ords`, `apex`).
*   **3-Tasemeline Prioriteedi Ahel (Images & ZIPs):**
    1. *Tase 1:* Kohalik fail kaustades `apex/`, `ords/`, `patches/` (0 allalaadimist).
    2. *Tase 2:* `.env` faili globaalsed ülekirjutused (`ARTIFACTORY_DOCKER_REGISTRY`, `APEX_DOWNLOAD_URL`).
    3. *Tase 3:* Profiili YAML faili vaikimisi lingid ja registrid.
*   **Topoloogia & Portide Lahendaja:** [resolve-topology.sh](file://${SCRIPT_DIR}/../scripts/internal/resolve-topology.sh) lahendab mitme sama profiiliga instantsi käivitamisel portide ja mahutite konfliktid.
*   **Dokumentatsioon:** Täielik kasutusjuhend asub failis [docs/db-profiles-and-topology.md](file://${SCRIPT_DIR}/../docs/db-profiles-and-topology.md).

---

## 7. Alamkomponentide & Kogu Süsteemi Automaattestimise Raamistik

**Staatus:** Teostatud & Valideeritud ✅

### Kirjeldus & Tehniline Visioon
Sarnaselt loodud automaattestijale `tests/test-db-profiles-and-topology.sh` luuakse modulaarne **kogu süsteemi ja alamkomponentide automaattestimise skript** (`tests/test-all-subcomponents.sh` või `tests/test-e2e-system.sh`), mis verifitseerib automaatselt 0-käsitööga:

1. **Alamkomponentide isoleeritud testid (Subcomponent Unit Tests):**
   - **ORDS REST Controller:** Pärib automaatselt `curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/ords/test_dev/_sdw/` ning kinnitab `200 OK` tulemuse.
   - **APEX Engine & Static Assets:** Verifitseerib APEXi staatiliste failide (`/i/24.1/apex_ui/css/core.min.css`) kättesaadavuse.
   - **Wallet Credential Storage:** Käivitab `./scripts/internal/view-wallet-credential.sh ADMIN` ja kontrollib väljundi terviklikkust.
   - **SSL/TLS Juursertifikaat:** Kontrollib `security find-certificate` või `certutil` kaudu, et sertifikaat on süsteemi hoidlas aktiivne.

2. **Kogu süsteemi E2E automaattest (Full E2E Integration Suite):**
   - Käivitab järjestikuse testitöövoo: puhastus (`reset-all.sh`), profiili laadimine, paigaldus (`setup-all.sh`), veebiteenuste NFR kontroll ning lõplik roheline testiaruanne.


