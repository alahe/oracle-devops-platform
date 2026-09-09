# Alustan Usein Kysytyt Kysymykset (UKK)

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/faq.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/faq.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/faq.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/faq.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/faq.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/faq.md)

> Keskitetty tietolähde (SSOT), joka kattaa arkkitehtuurin, Zero-Trust-tietoturvan, aloituksen ja vianmäärityksen.

---

**Jump to category:** [Aloittelija ja perusteet](#beginner) • [Arkkitehtuuri ja pilvi](#architect) • [DBA ja tietoturva](#dba_security) • [Vianmääritys ja palautus](#troubleshooting)

---

<a id="beginner"></a>
## Aloittelija ja perusteet

<details class="faq-item" id="faq-ram-requirements" data-cat="beginner">
<summary class="faq-summary"><strong>🧠 Mitkä ovat konttien muistivaatimukset (RAM min 4–8 Gt)?</strong> <span class="faq-cat-tag">Aloittelija ja perusteet</span></summary>

<div class="faq-body">

**Vastaus:** Oracle 23ai Free vaatii toimiakseen vähintään 2,5 Gt RAM-muistia. Jos Podman- tai Docker-virtuaalikoneelle on varattu alle 4 Gt, tietokantakontti pysähtyy odottamatta (OOM Killer / poistumiskoodi 137). Usean kontin malleissa varaa vähintään 8 Gt.

**Hyödylliset komennot:**
```bash
# Check and increase Podman VM memory (macOS / Windows WSL2):
podman machine stop
podman machine set --memory 8192 --cpus 4
podman machine start
```

**Liittyvät dokumentit ja skriptit:** [docs/prerequisites.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/prerequisites.md), [scripts/check-prerequisites.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-prerequisites.sh)

</div>
</details>

<details class="faq-item" id="faq-ssl-warning" data-cat="beginner">
<summary class="faq-summary"><strong>🔒 Miten käsitellä selaimen "Yhteys ei ole yksityinen" SSL-varoitus?</strong> <span class="faq-cat-tag">Aloittelija ja perusteet</span></summary>

<div class="faq-body">

**Vastaus:** Paikallinen HTTPS (https://localhost:8448) käyttää automaattisesti luotua itseallekirjoitettua varmennetta. Voit ohittaa varoituksen selaimessa tai asentaa varmenteen käyttöjärjestelmän luotettuihin juurivarmenteisiin.

**Hyödylliset komennot:**
```bash
# macOS Keychain trust:
./scripts/certs/trust-local-cert-mac.sh
# Windows CurrentUser trust (Zero-UAC):
./scripts/certs/trust-local-cert.cmd
```

**Liittyvät dokumentit ja skriptit:** [docs/ssl-certificates.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ssl-certificates.md), [scripts/certs/trust-local-cert-mac.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert-mac.sh)

</div>
</details>

<details class="faq-item" id="faq-stop-restart" data-cat="beginner">
<summary class="faq-summary"><strong>🌙 Miten keskeyttää ja käynnistää ympäristö työpäivän päätteeksi?</strong> <span class="faq-cat-tag">Aloittelija ja perusteet</span></summary>

<div class="faq-body">

**Vastaus:** Pysäytä kontit työpäivän päätteeksi vapauttaaksesi RAM- ja CPU-resurssit ilman tietojen menetystä. Käynnistä kontit aamulla uudelleen sekunneissa ilman asennuksen toistamista.

**Hyödylliset komennot:**
```bash
# Stop containers without data loss:
./scripts/reset-all.sh
# Resume existing containers in seconds:
./scripts/start-containers.sh
```

**Liittyvät dokumentit ja skriptit:** [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md), [scripts/start-containers.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/start-containers.sh), [scripts/reset-all.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/reset-all.sh)

</div>
</details>

<details class="faq-item" id="faq-vscode-connection" data-cat="beginner">
<summary class="faq-summary"><strong>💻 Miten muodostaa tietokantayhteys VS Code Oracle SQL Developerissa?</strong> <span class="faq-cat-tag">Aloittelija ja perusteet</span></summary>

<div class="faq-body">

**Vastaus:** Alusta sisältää automaattisen rekisteröintiskriptin, joka tallentaa tietokantayhteydet suoraan VS Coden asetuksiin (`dbtools-connections.json`) ja salasanat OS Keychainiin. Suorita register-connections.sh ja päivitä VS Code.

**Hyödylliset komennot:**
```bash
# Register connections automatically into VS Code:
./scripts/register-connections.sh
# Test connection via CLI:
./scripts/sqlcl.sh /@DB_PROXY_DEV
```

**Liittyvät dokumentit ja skriptit:** [docs/vscode-oracle-developer-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/vscode-oracle-developer-guide.md), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

</div>
</details>

<a id="architect"></a>
## Arkkitehtuuri ja pilvi

<details class="faq-item" id="faq-apex-vs-raw-code" data-cat="architect">
<summary class="faq-summary"><strong>🚀 Miksi valita APEX ja deklaratiiviset blueprintit raakakoodin generoimisen (React/Node) sijaan?</strong> <span class="faq-cat-tag">Arkkitehtuuri ja pilvi</span></summary>

<div class="faq-body">

**Vastaus:** Yli 10 000 rivin generoiminen React/Node-liimakoodia luo valtavan ylläpitovelan: tiimin on auditoitava, korjattava ja ylläpidettävä jokaista riviä. APEXissa deklaratiiviset blueprintit määrittelevät logiikan, ja alustan moottori hoitaa tietoturvan, istunnot ja nollaviiveisen SQL-suorituksen automaattisesti.

**Hyödylliset komennot:**
```bash
# Compile human-readable APEXlang DSL (.apx) into APEX application:
./scripts/sqlcl.sh /@DB_PROXY_DEV @apex/app_100.apx
```

**Liittyvät dokumentit ja skriptit:** [docs/architecture-overview.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/architecture-overview.md), [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md)

</div>
</details>

<details class="faq-item" id="faq-free-db-limits" data-cat="architect">
<summary class="faq-summary"><strong>💾 Riittävätkö Oracle Free DB:n resurssirajat (2 Gt RAM / 12 Gt dataa) yrityskehitykseen?</strong> <span class="faq-cat-tag">Arkkitehtuuri ja pilvi</span></summary>

<div class="faq-body">

**Vastaus:** Kyllä, ehdottomasti. Erottamalla käyttöliittymäkerroksen (Proxy DB) liiketoimintatietokannasta ja hyödyntämällä suoratoistavaa RESTiä, paikallinen levynkäyttö pysyy pienenä. Tuotantoon siirryttäessä sama koodi skaalautuu sellaisenaan Autonomous Databaseen.

**Hyödylliset komennot:**
```bash
# Hybrid deployment blueprint test:
./scripts/setup-all.sh --blueprint 10  # BP 10: Hybrid Cloud ADB
```

**Liittyvät dokumentit ja skriptit:** [docs/blueprints-overview.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/blueprints-overview.md), [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

</div>
</details>

<details class="faq-item" id="faq-version-control-cicd" data-cat="architect">
<summary class="faq-summary"><strong>📜 Miten versionhallinta, Liquibase ja turvallinen CI/CD taataan?</strong> <span class="faq-cat-tag">Arkkitehtuuri ja pilvi</span></summary>

<div class="faq-body">

**Vastaus:** Alusta noudattaa Git-keskeistä työnkulkua: viralliset SQLcl split-viennit, deklaratiiviset Liquibase-muutoslokit (`controller.xml`) ja APEXlang AST-tarkistukset. Salaisuuksia ei koskaan viedä Gitiin; putket käyttävät salasanatonta SEPS Walletia.

**Hyödylliset komennot:**
```bash
# Run offline local CI pipeline simulation:
./scripts/test-local-ci.sh
```

**Liittyvät dokumentit ja skriptit:** [docs/sqlcl-liquibase-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sqlcl-liquibase-guide.md), [scripts/test-local-ci.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/test-local-ci.sh)

</div>
</details>

<a id="dba_security"></a>
## DBA ja tietoturva

<details class="faq-item" id="faq-wallet-passwords" data-cat="dba_security">
<summary class="faq-summary"><strong>🔐 Missä salasanoja säilytetään? (SEPS Wallet vs tekstitiedostot)</strong> <span class="faq-cat-tag">DBA ja tietoturva</span></summary>

<div class="faq-body">

**Vastaus:** Tiukkojen Zero-Trust-periaatteiden (Sääntö 5) mukaisesti salasanoja EI KOSKAAN tallenneta levylle selkokielisinä. Kaikki tunnukset ovat AES-256-salattuina Oracle SEPS Walletissa (cwallet.sso / ewallet.p12). Salasanat puretaan vain muistiin get-password.sh-työkalulla.

**Hyödylliset komennot:**
```bash
# View password in terminal or copy directly to clipboard (-c):
./scripts/get-password.sh DB_PROXY_DEV
./scripts/get-password.sh DB_PROXY_DEV -c
# Connect passwordlessly via SEPS Wallet alias:
./scripts/sqlcl.sh /@DB_PROXY_DEV
```

**Liittyvät dokumentit ja skriptit:** [docs/wallet-management.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/wallet-management.md), [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [scripts/check-wallet.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-wallet.sh)

</div>
</details>

<details class="faq-item" id="faq-enterprise-proxy-artifactory" data-cat="dba_security">
<summary class="faq-summary"><strong>🏢 Toimiiko alusta yrityksen TLS-tarkastusta tekevien välityspalvelinten ja privaatti-Artifactoryn takana?</strong> <span class="faq-cat-tag">DBA ja tietoturva</span></summary>

<div class="faq-body">

**Vastaus:** Kyllä. Kaikki konttiviittaukset voidaan ohjata yrityksen sisäiseen Artifactory- tai Harbor-rekisteriin, korporaation CA-varmenteet injektoidaan kontteihin ja HTTP_PROXY-määrityksiä noudatetaan.

**Hyödylliset komennot:**
```bash
# Inspect corporate proxy and Artifactory compatibility:
./scripts/onboard-enterprise.sh --status
# Run non-destructive enterprise pre-flight checks:
./scripts/test-windows-dryrun.sh
```

**Liittyvät dokumentit ja skriptit:** [docs/enterprise-artifactory-and-proxy.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-artifactory-and-proxy.md), [scripts/onboard-enterprise.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/onboard-enterprise.sh)

</div>
</details>

<a id="troubleshooting"></a>
## Vianmääritys ja palautus

<details class="faq-item" id="faq-port-conflicts" data-cat="troubleshooting">
<summary class="faq-summary"><strong>🔌 Miten ratkaista porttiristiriidat (8448, 1521, 8080 varattu)?</strong> <span class="faq-cat-tag">Vianmääritys ja palautus</span></summary>

<div class="faq-body">

**Vastaus:** Jos terminaali ilmoittaa `bind: address already in use`, toinen verkkopalvelin tai Oracle listener varaa portin. Tunnista ja pysäytä häiritsevä prosessi tai vaihda isäntäporttia suoraan `.env`-tiedostossa.

**Hyödylliset komennot:**
```bash
# Identify conflicting process on port:
lsof -i :8448   # macOS/Linux
# Change port dynamically in .env:
HOST_HTTPS_PORT=8449
HOST_DB_PORT=1522
```

**Liittyvät dokumentit ja skriptit:** [docs/port-matrix-and-firewall.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/port-matrix-and-firewall.md), [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

</div>
</details>

<details class="faq-item" id="faq-golden-snapshots" data-cat="troubleshooting">
<summary class="faq-summary"><strong>⚡ Miten kultaisen pikavedoksen palautus toimii ~15 sekunnissa ilman uudelleenasennusta?</strong> <span class="faq-cat-tag">Vianmääritys ja palautus</span></summary>

<div class="faq-body">

**Vastaus:** Kultainen pikavedos tallentaa täysin konfiguroidun tietokannan tiedostot ja skeemat heti asennuksen valmistuttua. Uuden 12 minuutin asennuksen sijaan palautusskripti palauttaa puhtaan alkutilan noin 15 sekunnissa.

**Hyödylliset komennot:**
```bash
# Restore clean initial state of active blueprint in ~15s:
./scripts/snapshots/restore-golden-snapshots.sh
# Create golden snapshot manually:
./scripts/snapshots/create-golden-snapshots.sh
```

**Liittyvät dokumentit ja skriptit:** [docs/golden-snapshots.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/golden-snapshots.md), [scripts/snapshots/restore-golden-snapshots.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/restore-golden-snapshots.sh)

</div>
</details>

<details class="faq-item" id="faq-windows-wsl2-filesystem" data-cat="troubleshooting">
<summary class="faq-summary"><strong>🪟 Miksi tietovarasto on kloonattava WSL2 ext4 -järjestelmään eikä polkuun /mnt/c/?</strong> <span class="faq-cat-tag">Vianmääritys ja palautus</span></summary>

<div class="faq-body">

**Vastaus:** Säännön 14 mukaan Windows-liitospolun (`/mnt/c/...`) käyttö on ehdottomasti kielletty. Plan9-tiedostosillan I/O on 10–50x hitaampi ja se poistaa POSIX-oikeudet, mikä rikkoo SEPS Walletin (`chmod 0600`). Kloonaa aina kotihakemistoon `~/`.

**Hyödylliset komennot:**
```bash
# Clone inside native WSL2 Linux filesystem:
cd ~
git clone https://github.com/allanlahe/oracle-free-db-in-prod.git
cd oracle-free-db-in-prod
```

**Liittyvät dokumentit ja skriptit:** [docs/windows-wsl2-enterprise-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-wsl2-enterprise-setup.md), [scripts/check-prerequisites.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-prerequisites.sh)

</div>
</details>

