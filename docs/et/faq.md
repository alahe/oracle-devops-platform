# Platvormi Korduma Kippuvad Küsimused (KKK)

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/faq.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/faq.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/faq.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/faq.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/faq.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/faq.md)

> Tsentraalne infobaas (SSOT), mis katab arhitektuuri, Zero-Trust turvalisust, alustamist ja tõrkeotsingut.

---

**Jump to category:** [Alustaja ja põhitõed](#beginner) • [Arhitektuur ja pilv](#architect) • [DBA ja turvalisus](#dba_security) • [Tõrkeotsing ja taastamine](#troubleshooting)

---

<a id="beginner"></a>
## Alustaja ja põhitõed

<details class="faq-item" id="faq-ram-requirements" data-cat="beginner">
<summary class="faq-summary"><strong>🧠 Millised on konteinerite muutmälu (RAM) nõuded (min 4–8 GB)?</strong> <span class="faq-cat-tag">Alustaja ja põhitõed</span></summary>

<div class="faq-body">

**Vastus:** Oracle 23ai Free vajab töötamiseks vähemalt 2.5 GB RAM-i. Kui Podmani või Dockeri virtuaalmasinal on alla 4 GB mälu, peatub andmebaasi konteiner ootamatult (OOM Killer / exit code 137). Mitme konteineriga kavandite (Proxy + Äribaas + ORDS + Forms) puhul määrake vähemalt 8 GB RAM-i.

**Kasulikud käsud:**
```bash
# Check and increase Podman VM memory (macOS / Windows WSL2):
podman machine stop
podman machine set --memory 8192 --cpus 4
podman machine start
```

**Seotud dokumentatsioon ja skriptid:** [docs/prerequisites.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/prerequisites.md), [scripts/check-prerequisites.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-prerequisites.sh)

</div>
</details>

<details class="faq-item" id="faq-ssl-warning" data-cat="beginner">
<summary class="faq-summary"><strong>🔒 Kuidas lahendada brauseri "Ühendus pole privaatne" SSL hoiatus?</strong> <span class="faq-cat-tag">Alustaja ja põhitõed</span></summary>

<div class="faq-body">

**Vastus:** Lokaalne HTTPS (https://localhost:8448) kasutab kohalikku isesertifitseeritud sertifikaati. Klõpsake brauseris 'Advanced' -> 'Proceed to localhost' või lisage sertifikaat süsteemi usaldusnimekirja kaasasolevate 0-admin skriptidega.

**Kasulikud käsud:**
```bash
# macOS Keychain trust:
./scripts/certs/trust-local-cert-mac.sh
# Windows CurrentUser trust (Zero-UAC):
./scripts/certs/trust-local-cert.cmd
```

**Seotud dokumentatsioon ja skriptid:** [docs/ssl-certificates.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ssl-certificates.md), [scripts/certs/trust-local-cert-mac.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert-mac.sh)

</div>
</details>

<details class="faq-item" id="faq-stop-restart" data-cat="beginner">
<summary class="faq-summary"><strong>🌙 Kuidas tööpäeva lõpus keskkonda peatada ja uuesti käivitada?</strong> <span class="faq-cat-tag">Alustaja ja põhitõed</span></summary>

<div class="faq-body">

**Vastus:** Tööpäeva lõpus peatage konteinerid arvuti ressursside vabastamiseks ilma andmekaota. Hommikul taaskäivitage olemasolevad konteinerid sekunditega ilma paigaldust uuesti tegemata.

**Kasulikud käsud:**
```bash
# Stop containers without data loss:
./scripts/reset-all.sh
# Resume existing containers in seconds:
./scripts/start-containers.sh
```

**Seotud dokumentatsioon ja skriptid:** [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md), [scripts/start-containers.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/start-containers.sh), [scripts/reset-all.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/reset-all.sh)

</div>
</details>

<details class="faq-item" id="faq-vscode-connection" data-cat="beginner">
<summary class="faq-summary"><strong>💻 Kuidas luua andmebaasiühendus VS Code Oracle SQL Developeris?</strong> <span class="faq-cat-tag">Alustaja ja põhitõed</span></summary>

<div class="faq-body">

**Vastus:** Platvormil on automaatne registreerimisskript, mis kirjutab andmebaasiühendused otse VS Code laienduse konfiguratsiooni (`dbtools-connections.json`) ning salvestab paroolid turvaliselt OS Keychaini. Käivitage register-connections.sh ja laadige VS Code uuesti.

**Kasulikud käsud:**
```bash
# Register connections automatically into VS Code:
./scripts/register-connections.sh
# Test connection via CLI:
./scripts/sqlcl.sh /@DB_PROXY_DEV
```

**Seotud dokumentatsioon ja skriptid:** [docs/vscode-oracle-developer-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/vscode-oracle-developer-guide.md), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

</div>
</details>

<a id="architect"></a>
## Arhitektuur ja pilv

<details class="faq-item" id="faq-apex-vs-raw-code" data-cat="architect">
<summary class="faq-summary"><strong>🚀 Miks valida APEX ja deklaratiivsed blueprintid toorkoodi (React/Node) genereerimise asemel?</strong> <span class="faq-cat-tag">Arhitektuur ja pilv</span></summary>

<div class="faq-body">

**Vastus:** 10 000+ rea imperatiivse React/Node liimkoodi genereerimisel võtab meeskond endale tohutu pikaajalise hooldusvõla ja vastutuse iga koodirea auditeerimise ja silumise eest. APEXis on kavand nagu kõrgtaseme spetsifikatsioonikeel (APEXlang), kus turvalisuse, sessioonihalduse ja 0ms latentsusega SQL-käituse tagab automaatselt sertifitseeritud platvormimootor.

**Kasulikud käsud:**
```bash
# Compile human-readable APEXlang DSL (.apx) into APEX application:
./scripts/sqlcl.sh /@DB_PROXY_DEV @apex/app_100.apx
```

**Seotud dokumentatsioon ja skriptid:** [docs/architecture-overview.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/architecture-overview.md), [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md)

</div>
</details>

<details class="faq-item" id="faq-free-db-limits" data-cat="architect">
<summary class="faq-summary"><strong>💾 Kas Oracle Free DB ressursipiirangud (2 GB RAM / 12 GB andmeid) ei jää kitsaks?</strong> <span class="faq-cat-tag">Arhitektuur ja pilv</span></summary>

<div class="faq-body">

**Vastus:** Jah, kindlasti. Eraldades veebiliidese (Proxy DB) äribaasist ning kasutades null-jalajäljega REST-voogedastust (AutoREST / ORDS), hoitakse lokaalne andmemaht kompaktsena. Toodangusse liikudes skaleerub sama kood ilma muudatusteta otse Oracle Autonomous Database (ADB) pilvebaasi.

**Kasulikud käsud:**
```bash
# Hybrid deployment blueprint test:
./scripts/setup-all.sh --blueprint 10  # BP 10: Hybrid Cloud ADB
```

**Seotud dokumentatsioon ja skriptid:** [docs/blueprints-overview.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/blueprints-overview.md), [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

</div>
</details>

<details class="faq-item" id="faq-version-control-cicd" data-cat="architect">
<summary class="faq-summary"><strong>📜 Kuidas tagatakse versioonihaldus, Liquibase koodiajalugu ja CI/CD?</strong> <span class="faq-cat-tag">Arhitektuur ja pilv</span></summary>

<div class="faq-body">

**Vastus:** Platvorm kasutab Git-keskset töövoogu: ametlikud SQLcl split-ekspordid, deklaratiivsed Liquibase muudatuste logid (`controller.xml`) ja APEXlang AST valideerimine. Paroole ei panda kunagi Giti; CI/CD torud ühenduvad paroolivaba SEPS Walleti või efemeersete konteinerite kaudu ilma pilvesõltuvuseta.

**Kasulikud käsud:**
```bash
# Run offline local CI pipeline simulation:
./scripts/test-local-ci.sh
```

**Seotud dokumentatsioon ja skriptid:** [docs/sqlcl-liquibase-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sqlcl-liquibase-guide.md), [scripts/test-local-ci.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/test-local-ci.sh)

</div>
</details>

<a id="dba_security"></a>
## DBA ja turvalisus

<details class="faq-item" id="faq-wallet-passwords" data-cat="dba_security">
<summary class="faq-summary"><strong>🔐 Kus asuvad paroolid? (SEPS Wallet vs tekstifailid)</strong> <span class="faq-cat-tag">DBA ja turvalisus</span></summary>

<div class="faq-body">

**Vastus:** Rangete Zero-Trust reeglite (Reegel 5) järgi ei kirjutata paroole KUNAGI kettale tekstifailidesse (.txt, .json, .env). Kõik mandaadid asuvad krüpteeritult SEPS Auto-Login Walletis (cwallet.sso / ewallet.p12 AES-256 krüptoga). Paroolid deküpteeritakse ainult töömällu käsureatööriistaga get-password.sh.

**Kasulikud käsud:**
```bash
# View password in terminal or copy directly to clipboard (-c):
./scripts/get-password.sh DB_PROXY_DEV
./scripts/get-password.sh DB_PROXY_DEV -c
# Connect passwordlessly via SEPS Wallet alias:
./scripts/sqlcl.sh /@DB_PROXY_DEV
```

**Seotud dokumentatsioon ja skriptid:** [docs/wallet-management.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/wallet-management.md), [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [scripts/check-wallet.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-wallet.sh)

</div>
</details>

<details class="faq-item" id="faq-enterprise-proxy-artifactory" data-cat="dba_security">
<summary class="faq-summary"><strong>🏢 Kas platvorm töötab ettevõtte TLS-kontrolli teostavate prokside ja privaatse Artifactory taga?</strong> <span class="faq-cat-tag">DBA ja turvalisus</span></summary>

<div class="faq-body">

**Vastus:** Jah. Platvorm järgib Reeglit 4 (efemeerse konteineri muster) ja ettevõtte standardeid. Kõik konteineritõmmiste aadressid on suunatavad ettevõtte sisesesse Artifactorysse või Harborisse, korporatiivsed Root CA sertifikaadid seotakse konteineritega ning HTTP_PROXY muutujad võetakse arvesse.

**Kasulikud käsud:**
```bash
# Inspect corporate proxy and Artifactory compatibility:
./scripts/onboard-enterprise.sh --status
# Run non-destructive enterprise pre-flight checks:
./scripts/test-windows-dryrun.sh
```

**Seotud dokumentatsioon ja skriptid:** [docs/enterprise-artifactory-and-proxy.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-artifactory-and-proxy.md), [scripts/onboard-enterprise.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/onboard-enterprise.sh)

</div>
</details>

<a id="troubleshooting"></a>
## Tõrkeotsing ja taastamine

<details class="faq-item" id="faq-port-conflicts" data-cat="troubleshooting">
<summary class="faq-summary"><strong>🔌 Kuidas lahendada pordi konflikte (8448, 1521, 8080 hõivatud)?</strong> <span class="faq-cat-tag">Tõrkeotsing ja taastamine</span></summary>

<div class="faq-body">

**Vastus:** Kui terminal annab vea `bind: address already in use`, tööta taustal teine veebiserver, konteiner või lokaalne Oracle listener. Tuvastage ja peatage konfliktne protsess või muutke host-porti mugavalt failis `.env` ilma skripte muutmata.

**Kasulikud käsud:**
```bash
# Identify conflicting process on port:
lsof -i :8448   # macOS/Linux
# Change port dynamically in .env:
HOST_HTTPS_PORT=8449
HOST_DB_PORT=1522
```

**Seotud dokumentatsioon ja skriptid:** [docs/port-matrix-and-firewall.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/port-matrix-and-firewall.md), [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

</div>
</details>

<details class="faq-item" id="faq-golden-snapshots" data-cat="troubleshooting">
<summary class="faq-summary"><strong>⚡ Kuidas töötab kuldse hetktõmmise taastamine ~15 sekundiga ilma uuesti paigaldamata?</strong> <span class="faq-cat-tag">Tõrkeotsing ja taastamine</span></summary>

<div class="faq-body">

**Vastus:** Kuldne hetktõmmis (Golden Snapshot) talletab täielikult paigaldatud ja seadistatud andmebaasifailid, skeemid ja metastruktuurid kohe pärast paigalduse lõppu. Uue 12-minutilise paigalduse asemel taastab skript puhta algseisu umbes 15 sekundiga.

**Kasulikud käsud:**
```bash
# Restore clean initial state of active blueprint in ~15s:
./scripts/snapshots/restore-golden-snapshots.sh
# Create golden snapshot manually:
./scripts/snapshots/create-golden-snapshots.sh
```

**Seotud dokumentatsioon ja skriptid:** [docs/golden-snapshots.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/golden-snapshots.md), [scripts/snapshots/restore-golden-snapshots.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/restore-golden-snapshots.sh)

</div>
</details>

<details class="faq-item" id="faq-windows-wsl2-filesystem" data-cat="troubleshooting">
<summary class="faq-summary"><strong>🪟 Miks peab repositoorium asuma WSL2 ext4 failisüsteemis ja MITTE /mnt/c/ all?</strong> <span class="faq-cat-tag">Tõrkeotsing ja taastamine</span></summary>

<div class="faq-body">

**Vastus:** Reegli 14 järgi on Windowsi kettahaake (`/mnt/c/...`) alt käivitamine rangelt keelatud. Plan9 (9P) sild Linuxi ja NTFS-i vahel on 10–50 korda aeglasem ning nullib Linuxi failiõigused, mistõttu SEPS Wallet ei toimi (`chmod 0600` ebaõnnestub). Kloonige repo alati kasutaja kodukausta `~/oracle-free-db-in-prod`.

**Kasulikud käsud:**
```bash
# Clone inside native WSL2 Linux filesystem:
cd ~
git clone https://github.com/allanlahe/oracle-free-db-in-prod.git
cd oracle-free-db-in-prod
```

**Seotud dokumentatsioon ja skriptid:** [docs/windows-wsl2-enterprise-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-wsl2-enterprise-setup.md), [scripts/check-prerequisites.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-prerequisites.sh)

</div>
</details>

