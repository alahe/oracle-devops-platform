# Biežāk Uzdotie Jautājumi (BUJ)

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/faq.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/faq.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/faq.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/faq.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/faq.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/faq.md)

> Vienotais informācijas avots (SSOT) par arhitektūru, Zero-Trust drošību, darba sākšanu un traucējummeklēšanu.

---

**Jump to category:** [Iesācējs un pamati](#beginner) • [Arhitektūra un mākonis](#architect) • [DBA un drošība](#dba_security) • [Traucējummeklēšana un atkopšana](#troubleshooting)

---

<a id="beginner"></a>
## Iesācējs un pamati

<details class="faq-item" id="faq-ram-requirements" data-cat="beginner">
<summary class="faq-summary"><strong>🧠 Kādas ir konteineru operatīvās atmiņas (RAM) prasības (min 4–8 GB)?</strong> <span class="faq-cat-tag">Iesācējs un pamati</span></summary>

<div class="faq-body">

**Atbilde:** Oracle 23ai Free darbībai nepieciešami vismaz 2,5 GB RAM. Ja Podman vai Docker virtuālajai mašīnai piešķirts mazāk par 4 GB, datubāzes konteiners negaidīti apstāsies (OOM Killer / izejas kods 137). Vairāku konteineru scenārijiem piešķiriet vismaz 8 GB.

**Noderīgas komandas:**
```bash
# Check and increase Podman VM memory (macOS / Windows WSL2):
podman machine stop
podman machine set --memory 8192 --cpus 4
podman machine start
```

**Saistītā dokumentācija un skripti:** [docs/prerequisites.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/prerequisites.md), [scripts/check-prerequisites.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-prerequisites.sh)

</div>
</details>

<details class="faq-item" id="faq-ssl-warning" data-cat="beginner">
<summary class="faq-summary"><strong>🔒 Kā novērst pārlūka SSL brīdinājumu "Savienojums nav privāts"?</strong> <span class="faq-cat-tag">Iesācējs un pamati</span></summary>

<div class="faq-body">

**Atbilde:** Vietējais HTTPS (https://localhost:8448) izmanto pašparakstītu sertifikātu. Pārlūkā nospiediet 'Advanced' -> 'Proceed to localhost' vai pievienojiet to sistēmas uzticamajiem sertifikātiem.

**Noderīgas komandas:**
```bash
# macOS Keychain trust:
./scripts/certs/trust-local-cert-mac.sh
# Windows CurrentUser trust (Zero-UAC):
./scripts/certs/trust-local-cert.cmd
```

**Saistītā dokumentācija un skripti:** [docs/ssl-certificates.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ssl-certificates.md), [scripts/certs/trust-local-cert-mac.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert-mac.sh)

</div>
</details>

<details class="faq-item" id="faq-stop-restart" data-cat="beginner">
<summary class="faq-summary"><strong>🌙 Kā darba dienas beigās apturēt un atsākt vides darbību?</strong> <span class="faq-cat-tag">Iesācējs un pamati</span></summary>

<div class="faq-body">

**Atbilde:** Darba dienas beigās apturiet konteinerus, lai atbrīvotu datora resursus bez datu zuduma. No rīta palaidiet tos dažu sekunžu laikā bez atkārtotas uzstādīšanas.

**Noderīgas komandas:**
```bash
# Stop containers without data loss:
./scripts/reset-all.sh
# Resume existing containers in seconds:
./scripts/start-containers.sh
```

**Saistītā dokumentācija un skripti:** [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md), [scripts/start-containers.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/start-containers.sh), [scripts/reset-all.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/reset-all.sh)

</div>
</details>

<details class="faq-item" id="faq-vscode-connection" data-cat="beginner">
<summary class="faq-summary"><strong>💻 Kā izveidot savienojumu ar datubāzēm VS Code Oracle SQL Developer?</strong> <span class="faq-cat-tag">Iesācējs un pamati</span></summary>

<div class="faq-body">

**Atbilde:** Platforma piedāvā automātisku reģistrācijas skriptu, kas konfigurē savienojumus tieši VS Code (`dbtools-connections.json`) un paroles saglabā sistēmas atslēgu glabātavā. Palaidiet register-connections.sh.

**Noderīgas komandas:**
```bash
# Register connections automatically into VS Code:
./scripts/register-connections.sh
# Test connection via CLI:
./scripts/sqlcl.sh /@DB_PROXY_DEV
```

**Saistītā dokumentācija un skripti:** [docs/vscode-oracle-developer-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/vscode-oracle-developer-guide.md), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

</div>
</details>

<a id="architect"></a>
## Arhitektūra un mākonis

<details class="faq-item" id="faq-apex-vs-raw-code" data-cat="architect">
<summary class="faq-summary"><strong>🚀 Kāpēc izvēlēties APEX un deklaratīvos plānus, nevis AI ģenerētu kodu (React/Node)?</strong> <span class="faq-cat-tag">Arhitektūra un mākonis</span></summary>

<div class="faq-body">

**Atbilde:** Masveida React/Node koda ģenerēšana rada milzīgu uzturēšanas parādu un atbildību par katru rindu. APEX deklaratīvie plāni definē biznesa prasības, bet drošību, sesijas un 0ms izpildi nodrošina pārbaudīts datubāzes dzinējs.

**Noderīgas komandas:**
```bash
# Compile human-readable APEXlang DSL (.apx) into APEX application:
./scripts/sqlcl.sh /@DB_PROXY_DEV @apex/app_100.apx
```

**Saistītā dokumentācija un skripti:** [docs/architecture-overview.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/architecture-overview.md), [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md)

</div>
</details>

<details class="faq-item" id="faq-free-db-limits" data-cat="architect">
<summary class="faq-summary"><strong>💾 Vai Oracle Free DB ierobežojumi (2 GB RAM / 12 GB dati) ir pietiekami izstrādei?</strong> <span class="faq-cat-tag">Arhitektūra un mākonis</span></summary>

<div class="faq-body">

**Atbilde:** Jā, pilnīgi noteikti. Atdalot saskarni (Proxy DB) no biznesa datubāzes un izmantojot REST straumēšanu, diska patēriņš ir minimāls. Ražošanā risinājums bez izmaiņām mērogojas uz Oracle Autonomous Database.

**Noderīgas komandas:**
```bash
# Hybrid deployment blueprint test:
./scripts/setup-all.sh --blueprint 10  # BP 10: Hybrid Cloud ADB
```

**Saistītā dokumentācija un skripti:** [docs/blueprints-overview.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/blueprints-overview.md), [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

</div>
</details>

<details class="faq-item" id="faq-version-control-cicd" data-cat="architect">
<summary class="faq-summary"><strong>📜 Kā tiek nodrošināta versiju kontrole, Liquibase un droša CI/CD?</strong> <span class="faq-cat-tag">Arhitektūra un mākonis</span></summary>

<div class="faq-body">

**Atbilde:** Platforma izmanto Git darba plūsmu: SQLcl sadalītie eksporti, Liquibase izmaiņu žurnāli (`controller.xml`) un APEXlang AST validācijas. Paroles netiek glabātas Git; CI/CD izmanto bezparoļu SEPS makus.

**Noderīgas komandas:**
```bash
# Run offline local CI pipeline simulation:
./scripts/test-local-ci.sh
```

**Saistītā dokumentācija un skripti:** [docs/sqlcl-liquibase-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sqlcl-liquibase-guide.md), [scripts/test-local-ci.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/test-local-ci.sh)

</div>
</details>

<a id="dba_security"></a>
## DBA un drošība

<details class="faq-item" id="faq-wallet-passwords" data-cat="dba_security">
<summary class="faq-summary"><strong>🔐 Kur tiek glabātas paroles? (SEPS Wallet vs teksta faili)</strong> <span class="faq-cat-tag">DBA un drošība</span></summary>

<div class="faq-body">

**Atbilde:** Saskaņā ar Zero-Trust principiem (5. noteikums) paroles NEKAD netiek saglabātas atklātā tekstā. Visi dati atrodas šifrēti Oracle SEPS makā (cwallet.sso / ewallet.p12). Paroles tiek nolasītas tikai operatīvajā atmiņā caur get-password.sh.

**Noderīgas komandas:**
```bash
# View password in terminal or copy directly to clipboard (-c):
./scripts/get-password.sh DB_PROXY_DEV
./scripts/get-password.sh DB_PROXY_DEV -c
# Connect passwordlessly via SEPS Wallet alias:
./scripts/sqlcl.sh /@DB_PROXY_DEV
```

**Saistītā dokumentācija un skripti:** [docs/wallet-management.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/wallet-management.md), [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [scripts/check-wallet.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-wallet.sh)

</div>
</details>

<details class="faq-item" id="faq-enterprise-proxy-artifactory" data-cat="dba_security">
<summary class="faq-summary"><strong>🏢 Vai platforma darbojas aiz uzņēmuma TLS pārbaudes starpniekserveriem un privātā Artifactory?</strong> <span class="faq-cat-tag">DBA un drošība</span></summary>

<div class="faq-body">

**Atbilde:** Jā. Visus konteineru attēlus var novirzīt uz uzņēmuma iekšējo Artifactory vai Harbor, korporatīvie CA sertifikāti tiek pievienoti un tiek atbalstīti HTTP_PROXY iestatījumi.

**Noderīgas komandas:**
```bash
# Inspect corporate proxy and Artifactory compatibility:
./scripts/onboard-enterprise.sh --status
# Run non-destructive enterprise pre-flight checks:
./scripts/test-windows-dryrun.sh
```

**Saistītā dokumentācija un skripti:** [docs/enterprise-artifactory-and-proxy.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-artifactory-and-proxy.md), [scripts/onboard-enterprise.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/onboard-enterprise.sh)

</div>
</details>

<a id="troubleshooting"></a>
## Traucējummeklēšana un atkopšana

<details class="faq-item" id="faq-port-conflicts" data-cat="troubleshooting">
<summary class="faq-summary"><strong>🔌 Kā atrisināt portu konfliktus (8448, 1521, 8080 aizņemti)?</strong> <span class="faq-cat-tag">Traucējummeklēšana un atkopšana</span></summary>

<div class="faq-body">

**Atbilde:** Ja terminālī parādās kļūda `bind: address already in use`, kāds cits tīmekļa serveris vai klausītājs aizņem portu. Apturiet procesu vai nomainiet portu `.env` failā.

**Noderīgas komandas:**
```bash
# Identify conflicting process on port:
lsof -i :8448   # macOS/Linux
# Change port dynamically in .env:
HOST_HTTPS_PORT=8449
HOST_DB_PORT=1522
```

**Saistītā dokumentācija un skripti:** [docs/port-matrix-and-firewall.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/port-matrix-and-firewall.md), [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

</div>
</details>

<details class="faq-item" id="faq-golden-snapshots" data-cat="troubleshooting">
<summary class="faq-summary"><strong>⚡ Kā darbojas zelta momentuzņēmuma atjaunošana ~15 sekundēs bez pārinstalēšanas?</strong> <span class="faq-cat-tag">Traucējummeklēšana un atkopšana</span></summary>

<div class="faq-body">

**Atbilde:** Zelta momentuzņēmums fiksē pilnībā nokonfigurēto datubāzi tūlīt pēc uzstādīšanas. Tā vietā, lai gaidītu 12 minūtes jaunu instalāciju, skripts atjauno tīru stāvokli apmēram 15 sekundēs.

**Noderīgas komandas:**
```bash
# Restore clean initial state of active blueprint in ~15s:
./scripts/snapshots/restore-golden-snapshots.sh
# Create golden snapshot manually:
./scripts/snapshots/create-golden-snapshots.sh
```

**Saistītā dokumentācija un skripti:** [docs/golden-snapshots.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/golden-snapshots.md), [scripts/snapshots/restore-golden-snapshots.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/restore-golden-snapshots.sh)

</div>
</details>

<details class="faq-item" id="faq-windows-wsl2-filesystem" data-cat="troubleshooting">
<summary class="faq-summary"><strong>🪟 Kāpēc repozitorijs jāklonē WSL2 ext4, nevis zem /mnt/c/?</strong> <span class="faq-cat-tag">Traucējummeklēšana un atkopšana</span></summary>

<div class="faq-body">

**Atbilde:** Saskaņā ar 14. noteikumu palaišana no Windows montējuma (`/mnt/c/...`) ir aizliegta. Plan9 slānis ir 10–50x lēnāks un noņem POSIX tiesības (`chmod 0600`). Vienmēr klonējiet savā mājas mapē `~/`.

**Noderīgas komandas:**
```bash
# Clone inside native WSL2 Linux filesystem:
cd ~
git clone https://github.com/allanlahe/oracle-free-db-in-prod.git
cd oracle-free-db-in-prod
```

**Saistītā dokumentācija un skripti:** [docs/windows-wsl2-enterprise-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-wsl2-enterprise-setup.md), [scripts/check-prerequisites.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-prerequisites.sh)

</div>
</details>

