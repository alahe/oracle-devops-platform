# Dažniausiai Užduodami Klausimai (DUK)

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/faq.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/faq.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/faq.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/faq.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/faq.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/faq.md)

> Vieningas informacijos šaltinis (SSOT), apimantis architektūrą, Zero-Trust saugumą, pradžią ir trikčių šalinimą.

---

**Jump to category:** [Pradedantysis ir pagrindai](#beginner) • [Architektūra ir debesis](#architect) • [DBA ir saugumas](#dba_security) • [Trikčių šalinimas ir atkūrimas](#troubleshooting)

---

<a id="beginner"></a>
## Pradedantysis ir pagrindai

<details class="faq-item" id="faq-ram-requirements" data-cat="beginner">
<summary class="faq-summary"><strong>🧠 Kokie yra konteinerių operatyviosios atminties (RAM) reikalavimai (min 4–8 GB)?</strong> <span class="faq-cat-tag">Pradedantysis ir pagrindai</span></summary>

<div class="faq-body">

**Atsakymas:** Oracle 23ai Free reikalauja bent 2,5 GB RAM. Jei Podman ar Docker virtualiai mašinai priskirta mažiau nei 4 GB, duomenų bazės konteineris netikėtai sustos (OOM Killer / kodas 137). Kelių konteinerių konfigūracijoms skirkite bent 8 GB RAM.

**Naudingos komandos:**
```bash
# Check and increase Podman VM memory (macOS / Windows WSL2):
podman machine stop
podman machine set --memory 8192 --cpus 4
podman machine start
```

**Susijusi dokumentacija ir skriptai:** [docs/prerequisites.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/prerequisites.md), [scripts/check-prerequisites.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-prerequisites.sh)

</div>
</details>

<details class="faq-item" id="faq-ssl-warning" data-cat="beginner">
<summary class="faq-summary"><strong>🔒 Kaip išspręsti naršyklės SSL įspėjimą "Ryšys nėra privatus"?</strong> <span class="faq-cat-tag">Pradedantysis ir pagrindai</span></summary>

<div class="faq-body">

**Atsakymas:** Vietinis HTTPS (https://localhost:8448) naudoja savarankiškai pasirašytą sertifikatą. Naršyklėje pasirinkite 'Išsamiau' -> 'Eiti į localhost' arba įtraukite į sistemos patikimų sertifikatų sąrašą.

**Naudingos komandos:**
```bash
# macOS Keychain trust:
./scripts/certs/trust-local-cert-mac.sh
# Windows CurrentUser trust (Zero-UAC):
./scripts/certs/trust-local-cert.cmd
```

**Susijusi dokumentacija ir skriptai:** [docs/ssl-certificates.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ssl-certificates.md), [scripts/certs/trust-local-cert-mac.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert-mac.sh)

</div>
</details>

<details class="faq-item" id="faq-stop-restart" data-cat="beginner">
<summary class="faq-summary"><strong>🌙 Kaip darbo dienos pabaigoje pristabdyti ir vėl paleisti aplinką?</strong> <span class="faq-cat-tag">Pradedantysis ir pagrindai</span></summary>

<div class="faq-body">

**Atsakymas:** Darbo dienos pabaigoje sustabdykite konteinerius, kad atlaisvintumėte kompiuterio išteklius be duomenų praradimo. Ryte paleiskite juos per kelias sekundes be diegimo iš naujo.

**Naudingos komandos:**
```bash
# Stop containers without data loss:
./scripts/reset-all.sh
# Resume existing containers in seconds:
./scripts/start-containers.sh
```

**Susijusi dokumentacija ir skriptai:** [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md), [scripts/start-containers.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/start-containers.sh), [scripts/reset-all.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/reset-all.sh)

</div>
</details>

<details class="faq-item" id="faq-vscode-connection" data-cat="beginner">
<summary class="faq-summary"><strong>💻 Kaip prisijungti prie duomenų bazių VS Code Oracle SQL Developer?</strong> <span class="faq-cat-tag">Pradedantysis ir pagrindai</span></summary>

<div class="faq-body">

**Atsakymas:** Platforma turi automatinį registracijos skriptą, kuris įrašo ryšius tiesiai į VS Code (`dbtools-connections.json`) ir išsaugo slaptažodžius sistemos raktinėje. Paleiskite register-connections.sh.

**Naudingos komandos:**
```bash
# Register connections automatically into VS Code:
./scripts/register-connections.sh
# Test connection via CLI:
./scripts/sqlcl.sh /@DB_PROXY_DEV
```

**Susijusi dokumentacija ir skriptai:** [docs/vscode-oracle-developer-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/vscode-oracle-developer-guide.md), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

</div>
</details>

<a id="architect"></a>
## Architektūra ir debesis

<details class="faq-item" id="faq-apex-vs-raw-code" data-cat="architect">
<summary class="faq-summary"><strong>🚀 Kodėl verta rinktis APEX ir deklaratyvius planus vietoj generuoto kodo (React/Node)?</strong> <span class="faq-cat-tag">Architektūra ir debesis</span></summary>

<div class="faq-body">

**Atsakymas:** Sugeneravus 10 000+ eilučių React/Node kodo sukuriama didžiulė priežiūros skola. APEX atveju deklaratyvūs planai aprašo reikalavimus, o platformos branduolys automatiškai užtikrina saugumą, sesijas ir momentinį SQL vykdymą.

**Naudingos komandos:**
```bash
# Compile human-readable APEXlang DSL (.apx) into APEX application:
./scripts/sqlcl.sh /@DB_PROXY_DEV @apex/app_100.apx
```

**Susijusi dokumentacija ir skriptai:** [docs/architecture-overview.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/architecture-overview.md), [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md)

</div>
</details>

<details class="faq-item" id="faq-free-db-limits" data-cat="architect">
<summary class="faq-summary"><strong>💾 Ar pakanka Oracle Free DB ribų (2 GB RAM / 12 GB duomenų) verslo sistemų kūrimui?</strong> <span class="faq-cat-tag">Architektūra ir debesis</span></summary>

<div class="faq-body">

**Atsakymas:** Taip, visiškai. Atskyrus vartotojo sąsają (Proxy DB) nuo verslo duomenų bazės ir taikant REST perdavimą, disko sąnaudos lieka minimalios. Gamybinėje aplinkoje kodas perkeliamas tiesiai į Autonomous Database be pakeitimų.

**Naudingos komandos:**
```bash
# Hybrid deployment blueprint test:
./scripts/setup-all.sh --blueprint 10  # BP 10: Hybrid Cloud ADB
```

**Susijusi dokumentacija ir skriptai:** [docs/blueprints-overview.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/blueprints-overview.md), [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

</div>
</details>

<details class="faq-item" id="faq-version-control-cicd" data-cat="architect">
<summary class="faq-summary"><strong>📜 Kaip užtikrinamas versijų valdymas, Liquibase ir saugi CI/CD?</strong> <span class="faq-cat-tag">Architektūra ir debesis</span></summary>

<div class="faq-body">

**Atsakymas:** Platforma naudoja Git darbo eigą: SQLcl eksportai, Liquibase žurnalai (`controller.xml`) ir APEXlang AST patikros. Slaptažodžiai niekada nepatenka į Git; CI/CD naudoja saugią SEPS piniginę.

**Naudingos komandos:**
```bash
# Run offline local CI pipeline simulation:
./scripts/test-local-ci.sh
```

**Susijusi dokumentacija ir skriptai:** [docs/sqlcl-liquibase-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sqlcl-liquibase-guide.md), [scripts/test-local-ci.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/test-local-ci.sh)

</div>
</details>

<a id="dba_security"></a>
## DBA ir saugumas

<details class="faq-item" id="faq-wallet-passwords" data-cat="dba_security">
<summary class="faq-summary"><strong>🔐 Kur saugomi slaptažodžiai? (SEPS Wallet vs paprasto teksto failai)?</strong> <span class="faq-cat-tag">DBA ir saugumas</span></summary>

<div class="faq-body">

**Atsakymas:** Laikantis griežtų Zero-Trust taisyklių (5 taisyklė), slaptažodžiai NIEKADA neįrašomi į diską atviru tekstu. Visi duomenys šifruojami Oracle SEPS piniginėje (cwallet.sso / ewallet.p12). Slaptažodžiai iššifruojami tik atmintyje per get-password.sh.

**Naudingos komandos:**
```bash
# View password in terminal or copy directly to clipboard (-c):
./scripts/get-password.sh DB_PROXY_DEV
./scripts/get-password.sh DB_PROXY_DEV -c
# Connect passwordlessly via SEPS Wallet alias:
./scripts/sqlcl.sh /@DB_PROXY_DEV
```

**Susijusi dokumentacija ir skriptai:** [docs/wallet-management.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/wallet-management.md), [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [scripts/check-wallet.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-wallet.sh)

</div>
</details>

<details class="faq-item" id="faq-enterprise-proxy-artifactory" data-cat="dba_security">
<summary class="faq-summary"><strong>🏢 Ar platforma veikia už įmonės TLS tikrinančių tarpinių serverių ir privataus Artifactory?</strong> <span class="faq-cat-tag">DBA ir saugumas</span></summary>

<div class="faq-body">

**Atsakymas:** Taip. Visi konteinerių atvaizdai gali būti nukreipti į vidinį Artifactory arba Harbor registrą, įmonės CA sertifikatai integruojami į konteinerius, o HTTP_PROXY nustatymai palaikomi pilnai.

**Naudingos komandos:**
```bash
# Inspect corporate proxy and Artifactory compatibility:
./scripts/onboard-enterprise.sh --status
# Run non-destructive enterprise pre-flight checks:
./scripts/test-windows-dryrun.sh
```

**Susijusi dokumentacija ir skriptai:** [docs/enterprise-artifactory-and-proxy.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-artifactory-and-proxy.md), [scripts/onboard-enterprise.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/onboard-enterprise.sh)

</div>
</details>

<a id="troubleshooting"></a>
## Trikčių šalinimas ir atkūrimas

<details class="faq-item" id="faq-port-conflicts" data-cat="troubleshooting">
<summary class="faq-summary"><strong>🔌 Kaip išspręsti prievadų konfliktus (8448, 1521, 8080 užimti)?</strong> <span class="faq-cat-tag">Trikčių šalinimas ir atkūrimas</span></summary>

<div class="faq-body">

**Atsakymas:** Jei terminale rodoma `bind: address already in use`, kitas žiniatinklio serveris užima prievadą. Sustabdykite procesą arba pakeiskite prievadą `.env` faile.

**Naudingos komandos:**
```bash
# Identify conflicting process on port:
lsof -i :8448   # macOS/Linux
# Change port dynamically in .env:
HOST_HTTPS_PORT=8449
HOST_DB_PORT=1522
```

**Susijusi dokumentacija ir skriptai:** [docs/port-matrix-and-firewall.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/port-matrix-and-firewall.md), [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

</div>
</details>

<details class="faq-item" id="faq-golden-snapshots" data-cat="troubleshooting">
<summary class="faq-summary"><strong>⚡ Kaip veikia auksinės momentinės kopijos atkūrimas per ~15 sekundžių be diegimo iš naujo?</strong> <span class="faq-cat-tag">Trikčių šalinimas ir atkūrimas</span></summary>

<div class="faq-body">

**Atsakymas:** Auksinė momentinė kopija išsaugo pilnai sukonfigūruotą duomenų bazę iškart po įdiegimo. Vietoj naujo 12 minučių diegimo, skriptas atkuria pradinę būseną maždaug per 15 sekundžių.

**Naudingos komandos:**
```bash
# Restore clean initial state of active blueprint in ~15s:
./scripts/snapshots/restore-golden-snapshots.sh
# Create golden snapshot manually:
./scripts/snapshots/create-golden-snapshots.sh
```

**Susijusi dokumentacija ir skriptai:** [docs/golden-snapshots.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/golden-snapshots.md), [scripts/snapshots/restore-golden-snapshots.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/restore-golden-snapshots.sh)

</div>
</details>

<details class="faq-item" id="faq-windows-wsl2-filesystem" data-cat="troubleshooting">
<summary class="faq-summary"><strong>🪟 Kodėl saugykla turi būti klonuojama WSL2 ext4, o NE po /mnt/c/?</strong> <span class="faq-cat-tag">Trikčių šalinimas ir atkūrimas</span></summary>

<div class="faq-body">

**Atsakymas:** Pagal 14 taisyklę vykdymas iš Windows prijungimo (`/mnt/c/...`) yra griežtai draudžiamas. Plan9 I/O yra 10–50 kartų lėtesnis ir panaikina POSIX teises (`chmod 0600`). Visada klonuokite namų aplanke `~/`.

**Naudingos komandos:**
```bash
# Clone inside native WSL2 Linux filesystem:
cd ~
git clone https://github.com/allanlahe/oracle-free-db-in-prod.git
cd oracle-free-db-in-prod
```

**Susijusi dokumentacija ir skriptai:** [docs/windows-wsl2-enterprise-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-wsl2-enterprise-setup.md), [scripts/check-prerequisites.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-prerequisites.sh)

</div>
</details>

