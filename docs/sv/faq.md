# Vanliga Frågor och Svar (FAQ)

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/faq.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/faq.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/faq.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/faq.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/faq.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/faq.md)

> Central informationskälla (SSOT) för arkitektur, Zero-Trust-säkerhet, introduktion och felsökning.

---

**Jump to category:** [Nybörjare & grunder](#beginner) • [Arkitektur & moln](#architect) • [DBA & säkerhet](#dba_security) • [Felsökning & återställning](#troubleshooting)

---

<a id="beginner"></a>
## Nybörjare & grunder

<details class="faq-item" id="faq-ram-requirements" data-cat="beginner">
<summary class="faq-summary"><strong>🧠 Vilka är minneskraven (RAM min 4–8 GB) för containrar?</strong> <span class="faq-cat-tag">Nybörjare & grunder</span></summary>

<div class="faq-body">

**Svar:** Oracle 23ai Free kräver minst 2,5 GB RAM för att köras. Om din Podman- eller Docker-virtuella maskin har mindre än 4 GB minne stoppas databascontainern oväntat (OOM Killer / felkod 137). För flercontainermallar rekommenderas minst 8 GB RAM.

**Nyttiga kommandon:**
```bash
# Check and increase Podman VM memory (macOS / Windows WSL2):
podman machine stop
podman machine set --memory 8192 --cpus 4
podman machine start
```

**Relaterad dokumentation och skript:** [docs/prerequisites.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/prerequisites.md), [scripts/check-prerequisites.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-prerequisites.sh)

</div>
</details>

<details class="faq-item" id="faq-ssl-warning" data-cat="beginner">
<summary class="faq-summary"><strong>🔒 Hur hanteras webbläsarens SSL-varning "Anslutningen är inte privat"?</strong> <span class="faq-cat-tag">Nybörjare & grunder</span></summary>

<div class="faq-body">

**Svar:** Lokal HTTPS (https://localhost:8448) använder ett självsignerat rotcertifikat. Klicka på 'Avancerat' -> 'Fortsätt till localhost' eller installera certifikatet i systemets betrodda lager.

**Nyttiga kommandon:**
```bash
# macOS Keychain trust:
./scripts/certs/trust-local-cert-mac.sh
# Windows CurrentUser trust (Zero-UAC):
./scripts/certs/trust-local-cert.cmd
```

**Relaterad dokumentation och skript:** [docs/ssl-certificates.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ssl-certificates.md), [scripts/certs/trust-local-cert-mac.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert-mac.sh)

</div>
</details>

<details class="faq-item" id="faq-stop-restart" data-cat="beginner">
<summary class="faq-summary"><strong>🌙 Hur pausar och startar man om miljön vid arbetsdagens slut?</strong> <span class="faq-cat-tag">Nybörjare & grunder</span></summary>

<div class="faq-body">

**Svar:** Vid arbetsdagens slut stoppar du containrarna för att frigöra RAM och CPU utan att förlora data. Starta om dem på några sekunder nästa morgon utan ominstallation.

**Nyttiga kommandon:**
```bash
# Stop containers without data loss:
./scripts/reset-all.sh
# Resume existing containers in seconds:
./scripts/start-containers.sh
```

**Relaterad dokumentation och skript:** [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md), [scripts/start-containers.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/start-containers.sh), [scripts/reset-all.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/reset-all.sh)

</div>
</details>

<details class="faq-item" id="faq-vscode-connection" data-cat="beginner">
<summary class="faq-summary"><strong>💻 Hur ansluter man till databaser i VS Code Oracle SQL Developer?</strong> <span class="faq-cat-tag">Nybörjare & grunder</span></summary>

<div class="faq-body">

**Svar:** Plattformen har ett automatiserat registreringsskript som skriver anslutningar direkt till VS Code (`dbtools-connections.json`) och sparar lösenord säkert i OS Keychain. Kör register-connections.sh och ladda om VS Code.

**Nyttiga kommandon:**
```bash
# Register connections automatically into VS Code:
./scripts/register-connections.sh
# Test connection via CLI:
./scripts/sqlcl.sh /@DB_PROXY_DEV
```

**Relaterad dokumentation och skript:** [docs/vscode-oracle-developer-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/vscode-oracle-developer-guide.md), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

</div>
</details>

<a id="architect"></a>
## Arkitektur & moln

<details class="faq-item" id="faq-apex-vs-raw-code" data-cat="architect">
<summary class="faq-summary"><strong>🚀 Varför välja APEX och deklarativa blueprints istället för AI-genererad råkod (React/Node)?</strong> <span class="faq-cat-tag">Arkitektur & moln</span></summary>

<div class="faq-body">

**Svar:** Att generera 10 000+ rader imperativ React/Node-kod skapar en enorm underhållsskuld där teamet tvingas förvalta varje rad. I APEX definierar deklarativa blueprints logiken, medan motorn automatiskt hanterar säkerhet, sessioner och prestanda.

**Nyttiga kommandon:**
```bash
# Compile human-readable APEXlang DSL (.apx) into APEX application:
./scripts/sqlcl.sh /@DB_PROXY_DEV @apex/app_100.apx
```

**Relaterad dokumentation och skript:** [docs/architecture-overview.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/architecture-overview.md), [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md)

</div>
</details>

<details class="faq-item" id="faq-free-db-limits" data-cat="architect">
<summary class="faq-summary"><strong>💾 Räcker begränsningarna i Oracle Free DB (2 GB RAM / 12 GB användardata) för utveckling?</strong> <span class="faq-cat-tag">Arkitektur & moln</span></summary>

<div class="faq-body">

**Svar:** Ja, absolut. Genom att separera användargränssnittet (Proxy DB) från affärsdatabasen och använda REST-strömning hålls diskanvändningen minimal. Koden flyttas sömlöst till OCI Autonomous Database vid produktionsstart.

**Nyttiga kommandon:**
```bash
# Hybrid deployment blueprint test:
./scripts/setup-all.sh --blueprint 10  # BP 10: Hybrid Cloud ADB
```

**Relaterad dokumentation och skript:** [docs/blueprints-overview.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/blueprints-overview.md), [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

</div>
</details>

<details class="faq-item" id="faq-version-control-cicd" data-cat="architect">
<summary class="faq-summary"><strong>📜 Hur säkerställs versionshantering, Liquibase och säker CI/CD?</strong> <span class="faq-cat-tag">Arkitektur & moln</span></summary>

<div class="faq-body">

**Svar:** Plattformen tillämpar ett Git-först-arbetsflöde med SQLcl split-exporter, Liquibase changelogs (`controller.xml`) och AST-validering. Hemligheter sparas aldrig i Git; CI/CD-pipelines använder lösenordsfria SEPS Wallets.

**Nyttiga kommandon:**
```bash
# Run offline local CI pipeline simulation:
./scripts/test-local-ci.sh
```

**Relaterad dokumentation och skript:** [docs/sqlcl-liquibase-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sqlcl-liquibase-guide.md), [scripts/test-local-ci.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/test-local-ci.sh)

</div>
</details>

<a id="dba_security"></a>
## DBA & säkerhet

<details class="faq-item" id="faq-wallet-passwords" data-cat="dba_security">
<summary class="faq-summary"><strong>🔐 Var lagras lösenord? (SEPS Wallet vs klartextfiler)</strong> <span class="faq-cat-tag">DBA & säkerhet</span></summary>

<div class="faq-body">

**Svar:** Enligt strikta Zero-Trust-regler (Regel 5) skrivs lösenord ALDRIG till disk i klartext. Alla autentiseringsuppgifter är AES-256-krypterade i Oracle SEPS Wallet (cwallet.sso / ewallet.p12). Lösenord dekrypteras endast i minnet via get-password.sh.

**Nyttiga kommandon:**
```bash
# View password in terminal or copy directly to clipboard (-c):
./scripts/get-password.sh DB_PROXY_DEV
./scripts/get-password.sh DB_PROXY_DEV -c
# Connect passwordlessly via SEPS Wallet alias:
./scripts/sqlcl.sh /@DB_PROXY_DEV
```

**Relaterad dokumentation och skript:** [docs/wallet-management.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/wallet-management.md), [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [scripts/check-wallet.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-wallet.sh)

</div>
</details>

<details class="faq-item" id="faq-enterprise-proxy-artifactory" data-cat="dba_security">
<summary class="faq-summary"><strong>🏢 Fungerar plattformen bakom företagets TLS-inspekterande proxys och privata Artifactory?</strong> <span class="faq-cat-tag">DBA & säkerhet</span></summary>

<div class="faq-body">

**Svar:** Ja. Alla containeravbildningar kan konfigureras mot interna Artifactory- eller Harbor-speglar, företagets CA-certifikat injiceras i containrar och HTTP_PROXY stöds fullt ut.

**Nyttiga kommandon:**
```bash
# Inspect corporate proxy and Artifactory compatibility:
./scripts/onboard-enterprise.sh --status
# Run non-destructive enterprise pre-flight checks:
./scripts/test-windows-dryrun.sh
```

**Relaterad dokumentation och skript:** [docs/enterprise-artifactory-and-proxy.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-artifactory-and-proxy.md), [scripts/onboard-enterprise.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/onboard-enterprise.sh)

</div>
</details>

<a id="troubleshooting"></a>
## Felsökning & återställning

<details class="faq-item" id="faq-port-conflicts" data-cat="troubleshooting">
<summary class="faq-summary"><strong>🔌 Hur löser man portkonflikter (8448, 1521, 8080 upptagna)?</strong> <span class="faq-cat-tag">Felsökning & återställning</span></summary>

<div class="faq-body">

**Svar:** Om terminalen visar `bind: address already in use` körs en annan webbserver eller Oracle-lyssnare på den porten. Identifiera och avsluta processen eller ändra porten i `.env`-filen.

**Nyttiga kommandon:**
```bash
# Identify conflicting process on port:
lsof -i :8448   # macOS/Linux
# Change port dynamically in .env:
HOST_HTTPS_PORT=8449
HOST_DB_PORT=1522
```

**Relaterad dokumentation och skript:** [docs/port-matrix-and-firewall.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/port-matrix-and-firewall.md), [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

</div>
</details>

<details class="faq-item" id="faq-golden-snapshots" data-cat="troubleshooting">
<summary class="faq-summary"><strong>⚡ Hur fungerar återställning av gyllene ögonblicksbilder på ~15 sekunder?</strong> <span class="faq-cat-tag">Felsökning & återställning</span></summary>

<div class="faq-body">

**Svar:** En gyllene ögonblicksbild sparar en fullständigt konfigurerad databas direkt efter installationen. Istället för en ny 12 minuters installation återställer skriptet det orörda läget på cirka 15 sekunder.

**Nyttiga kommandon:**
```bash
# Restore clean initial state of active blueprint in ~15s:
./scripts/snapshots/restore-golden-snapshots.sh
# Create golden snapshot manually:
./scripts/snapshots/create-golden-snapshots.sh
```

**Relaterad dokumentation och skript:** [docs/golden-snapshots.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/golden-snapshots.md), [scripts/snapshots/restore-golden-snapshots.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/restore-golden-snapshots.sh)

</div>
</details>

<details class="faq-item" id="faq-windows-wsl2-filesystem" data-cat="troubleshooting">
<summary class="faq-summary"><strong>🪟 Varför måste repot klonas i WSL2 ext4 och INTE under /mnt/c/?</strong> <span class="faq-cat-tag">Felsökning & återställning</span></summary>

<div class="faq-body">

**Svar:** Enligt Regel 14 är körning från Windows-monteringen (`/mnt/c/...`) strängt förbjuden. Plan9-översättningen är 10–50x långsammare och tar bort Linux-rättigheter (`chmod 0600`). Klona alltid i hemkatalogen `~/`.

**Nyttiga kommandon:**
```bash
# Clone inside native WSL2 Linux filesystem:
cd ~
git clone https://github.com/allanlahe/oracle-free-db-in-prod.git
cd oracle-free-db-in-prod
```

**Relaterad dokumentation och skript:** [docs/windows-wsl2-enterprise-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-wsl2-enterprise-setup.md), [scripts/check-prerequisites.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-prerequisites.sh)

</div>
</details>

