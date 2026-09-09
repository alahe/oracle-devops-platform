[ 🇬🇧 English ](../future-plans.md) | [ 🇪🇪 Eesti ](future-plans.md) | [ 🇫🇮 Suomi ](../fi/future-plans.md) | [ 🇸🇪 Svenska ](../sv/future-plans.md) | [ 🇱🇻 Latviešu ](../lv/future-plans.md) | [ 🇱🇹 Lietuvių ](../lt/future-plans.md)

# 🛡️ Arenduskeskkonna laiendamise ja turvalisuse tulevikukava & audit

> [!NOTE]
> **Tulevikuplaanid on reorganiseeritud modulaarseks Backlog süsteemiks:**
> Kõik üksikud ülesanded, detailne arhitektuur ja elutsükkel asuvad nüüd kaustas **[`backlog/`](../../backlog/README.md)**:
> - 🟢 **Teostatud ülesanded:** [`backlog/done/`](../../backlog/done/)
> - 🟡 **Ootel / Kavandatavad ülesanded:** [`backlog/todo/`](../../backlog/todo/)
> - 📄 **Uue ülesande mall:** [`backlog/template.md`](../../backlog/template.md)

See dokument koondab projekti **reaalse teostusauditi (Staatuse Kontroll)**, realiseeritud funktsionaalsuste nimekirja ning tegemata turvatäienduste ja toodangukeskkonna nõuete kava.

---

## 📊 KOKKUVÕTLIK STAATUSE MAATRIKS (STATUS MATRIX)

| ID | Teema / Funktsionaalsus | Reaalne Staatus | Märkused |
|---|---|---|---|
| **1.1** | Konteineriseeritud Web IDE (`code-server`) | **✅ REALISEERITUD** | `web-ide` konteiner, OpenJDK 21, SQLcl, VS Code laiendused |
| **1.2** | GitHub Actions & Offline `act` CI/CD | **✅ REALISEERITUD** | `scripts/test-local-ci.sh`, `.dbtools/project.config.json` |
| **1.3** | Analytics Publisher (Pixel Perfect) paigaldus | **✅ REALISEERITUD** | `oracle/analyticsserver:2025`, HTTP 200 OK verifitseeritud |
| **1.4** | VS Code SQL Developer ühenduste automaatne registreering | **✅ REALISEERITUD** | `register-connections.sh`, kaustad `/APEX`, `/Publisher`, `/MYATP` |
| **1.5** | Ristplatvormne SSL Juursertifikaadi usaldamine | **✅ REALISEERITUD** | macOS `security`, Windows `certutil`, WSL interop |
| **1.6** | Dünaamiline YAML Andmebaasi Profiilide Mootor | **✅ REALISEERITUD** | 7 YAML profiili, `resolve-topology.sh` topoloogia lahendaja |
| **1.7** | Automaattestimise Raamistik (Unit & E2E) | **✅ REALISEERITUD** | `test-all-components.sh`, `test-e2e-system.sh`, unit testid |
| **2.1** | Vaikimisi Varuparoolide Eemaldamine (`OraclePass2026`) | **✅ REALISEERITUD** | Skriptidest eemaldatud fallback paroolid, päritakse SEPS Walletist/Secrets |
| **2.2** | WebLogic REST & Publisher HTTPS Reverse Proxy | **✅ REALISEERITUD** | Seadistatud Nginx TLS 1.3 reverse proxy (`publisher-ssl-proxy.conf`) |
| **3.1** | Konteinerite Pordi Isoleerimine (`127.0.0.1`) | **✅ REALISEERITUD** | Pordid on seotud rangelt kohaliku liidesega (`127.0.0.1`) |
| **3.2** | Rootless Konteinerite Režiim & Privileegide Piiramine | **✅ REALISEERITUD** | Lisatud `--security-opt=no-new-privileges` kõigile konteinerite käivitustele |
| **4.1** | Artifactory & Git žetoonide maskeerimine logides | **✅ REALISEERITUD** | Loodud `sanitize-logs.sh`, mis maskeerib logides `ACCESS_TOKEN` ja paroolid |
| **1.14** | Universaalne Reaalaegne Progress ja Puhverdamata Väljund | **✅ REALISEERITUD** | Option C `print_step_progress` & `sed -u` unbuffered filter kõigil sammudel |
| **1.15** | Viivitatud Tsentraalne Tervisekontrolli Arhitektuur | **✅ REALISEERITUD** | Üks tsentraalne lõppkontroll `test-urls.sh` (ORDS, APEX, Publisher, Web IDE) |
| **1.16** | LIS Süsteemi Üldine Põhiarhitektuur (4-Kihiline Mudel) | **✅ REALISEERITUD** | `publisher-free` + `proxy-gvenzl` + `app-free`, Outbound REST & ACL, DB-Link & Inbound Push |
| **1.17** | Automaatne Versiooni Tuvastamine (DB, APEX, ORDS) | **✅ REALISEERITUD** | Tuvastus otse konteineri pildilt (`podman image inspect`) ja standalone paketist (`binaries/ords/`) |
| **1.18** | Paigalduse Ajakulu Optimeerimine (APEX DB Kiirendus 15m ➔ 1–2m) | **✅ REALISEERITUD** | 4-sambaline lahendus: FastStart/Artifactory pildid, Golden Snapshot kiirtaastus (~30s), mälu tuunimine ja Runtime režiim (`TASK-018`) |
| **1.19** | Analytics Publisheri & Multi-DB Paigalduse Kiirendus | **✅ REALISEERITUD** | Pre-built WebLogic domeenipilt (~45s), konfigureeritav paralleelsus (`--parallel`), domeeniehitaja (`TASK-019`) |
| **1.20** | Multi-DB SEPS Wallet ja TNS Joondus | **✅ REALISEERITUD** | Mitme andmebaasi paralleelsed SEPS rahakotid ja `tnsnames.ora` sünkroonne haldus (`TASK-027`) |
| **1.21** | VS Code Walleti Kõigi Kasutajate Sünkroniseerimine | **✅ REALISEERITUD** | Automaatne kõigi skeemide ja rollide sidumine VS Code hoidlaga (`TASK-028`) |
| **1.22** | Oracle Forms 14c Konteiner ja noVNC Tugi | **✅ REALISEERITUD** | Forms 14c käituskeskkond, HTML5 noVNC Forms Builder GUI ja profiilid (`TASK-029`) |
| **1.23** | Kanonilised Konteineriprefiksitega SEPS Walletid | **✅ REALISEERITUD** | `DB_${PREFIX}_*` valem, zero-hardcoding ja mitme andmebaasi nimeruumide isoleerimine (`TASK-030`) |
| **1.24** | Terminali Progressi ja Ajakulu Kompaktne Kuvamine | **✅ REALISEERITUD** | Kohapeal uuenev TTY riba (`\r\033[K`), ajaloolised mõõdikud JSON-is, alam-sammude puuhierarhia (`TASK-025`) |
| **1.25** | `setup-all.sh` Blueprintide Nimekirja ja Info CLI Parameetrid | **✅ REALISEERITUD** | `--list-blueprints` (`-lb`), `--show-blueprint <N>`, `--search-blueprints`, `--dry-run` (`TASK-026`) |
| **2.13** | Future Plans Reorganiseerimine Modulaarseks Backlogiks | **✅ REALISEERITUD** | Eraldi failid `backlog/todo/` ja `backlog/done/` kaustades |
| **4.2** | Logide & Diagnostikafailide Puhastamine (`clean-logs.sh`) | **✅ REALISEERITUD** | Skript `scripts/clean-logs.sh` loodud ja testitud (`TASK-008`) |
| **5.1** | Ametlike Ettevõtte TLS Sertifikaatide (PKI) Tugi | **❌ REALISEERIMATA** | Kasutusel on kohalik iseallkirjastatud `localCA.pem` |
| **6.1** | OCI Always Free Pilvepaigalduse Reaalne Katse | **🟡 OSALISELT REALISEERITUD** | `deploy-remote.sh` valmis, pilve-test ootab sooritamist (`TASK-020`) |
| **6.2** | GitHub Actions CI/CD Reaalne Pilve-Tarne | **🟡 OSALISELT REALISEERITUD** | `deploy-remote-cloud.yml` valmis, pilvesekreedid ootavad (`TASK-020`) |
| **2.8** | Automaatne TDE (Transparent Data Encryption) Tugi | **🟡 OSALISELT REALISEERITUD** | Tablespace'ide AES-256 krüpteerimine kettal ja keystore võtid (`TASK-021`) |
| **2.9** | Loetav Juurfailisüsteem ja Rangem Hardening (`--read-only`) | **🟡 OSALISELT REALISEERITUD** | Konteinerite juurfailisüsteemi lukustamine ja `tmpfs` (`TASK-022`) |
| **2.10** | Keskne Auditilogi ja SIEM Integratsioon (Unified Auditing) | **❌ REALISEERIMATA** | Oracle Unified Auditing poliitikad ja logiforwarder (`TASK-023`) |
| **2.11** | WAF & OAuth2 / OIDC Entra-ID Lõiming REST API-dele | **🟡 OSALISELT REALISEERITUD** | Nginx WAF / ModSecurity ja ORDS REST OAuth2 Bearer kaitse (`TASK-024`) |

---

## 🟢 1. Realiseeritud ja Valideeritud Funktsionaalsused (Completed Features)

### 1.1 Konteineriseeritud Arendusvahendid (VS Code + SQL Developer + Git jne)
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [docs/web-ide-artifactory.md](web-ide-artifactory.md)
- **Reaalne kontroll:** Kontrollitud `web-ide` profiil ja Dockerfile. Pildil on pre-installeeritud OpenJDK 21, Oracle SQLcl, Liquibase, Git, Python3, GitHub CLI (`gh`), `act` CLI ja VS Code laiendused (`Oracle.sql-developer-for-vscode`, `github.vscode-github-actions`). Brauseri kaudu ligipääsetav aadressil `http://localhost:8090`.

### 1.2 GitHub Actions / CI/CD Töövoog & Lokaalne Offline Testimine Podmanis
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [docs/devops-lifecycle-guide.md](devops-lifecycle-guide.md)
- **Reaalne kontroll:** SQLcl Projects automatiseerimine (`.dbtools/project.config.json`), lokaalne simulaator [`./scripts/test-local-ci.sh`](../../scripts/test-local-ci.sh), Nektos `act` CLI ja VS Code laiendus `github.vscode-github-actions` on koodibaasis olemas ja funktsioneerivad.

### 1.3 Oracle Analytics Publisher (Pixel Perfect) Kohalik Käivitamine
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [docs/publisher-setup.md](publisher-setup.md)
- **Reaalne kontroll:** Paigaldus testitud ja verifitseeritud (`oracle/analyticsserver:2025`). Pordil `9502` tagastab `/xmlpserver/login.jsp` puhta **HTTP 200 OK** ning HTML tiitli `<title>Oracle Analytics Publisher Login</title>`.

### 1.4 VS Code Ühenduste Universaalne Registreerimine
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [connections/README.md](../../connections/README.md)
- **Reaalne kontroll:** Registreerib VS Code Oracle SQL Developer laiendusele automaatselt ühendused ja kaustad: `/APEX` (Standard DB), `/MYATP` (ADB režiim) ja `/Publisher` (Publisher DB).

### 1.5 Ristplatvormne SSL Juursertifikaadi Automaatne Kontroll & Usaldamine
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Reaalne kontroll:** `setup-all.sh` ja `generate-local-certs.sh` kontrollivad ja usaldavad kohalikku HTTPS juursertifikaati (`config/certs/localCA.pem`) operatsioonisüsteemi sertifikaadihoidlas (macOS Keychain `security`, Windows `certutil`, WSL interop).

### 1.6 Dünaamiline YAML Andmebaasi Profiilide Mootor & Topoloogia Haldur
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [docs/db-profiles-and-topology.md](../db-profiles-and-topology.md)
- **Reaalne kontroll:** 7 standardset YAML profiili (`config/profiles/*.yaml`), 3-tasemeline failide lahendamise ahel ning [resolve-topology.sh](../../scripts/internal/resolve-topology.sh) portide ja mahutite konfliktide lahendamiseks.

### 1.7 Alamkomponentide & Kogu Süsteemi Automaattestimise Raamistik
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [tests/README.md](../../tests/README.md)
- **Reaalne kontroll:** Modulaarne automaattestimise raamistik ([test-all-components.sh](../../tests/test-all-components.sh) ja [test-e2e-system.sh](../../tests/integration/test-e2e-system.sh)), mis kontrollib 0-käsitööga ORDS REST kontrolle, APEX mootorit, Walleti paroole ja SSL sertifikaate.

### 1.8 Logide & Diagnostikafailide Puhastamine (`clean-logs.sh`)
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [scripts/README.md](../../scripts/README.md)
- **Reaalne kontroll:** Skript [`./scripts/clean-logs.sh`](../../scripts/clean-logs.sh) kustutab `install_logs/*.log` failid, `unzipped_log*` kataloogid ning `bieeconfiglogs*.zip` arhiivid. Läbis automaattesti `test-script-clean-logs.sh`.

### 1.9 Vaikimisi Varuparoolide Eemaldamine
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Eemaldatud kõigist skriptidest (`install-publisher.sh`, `init-publisher-rcu.sh`, `deploy-publisher-reports.sh`, `createAndStartDomain.sh`) kõvakodeeritud varuparoolid `OraclePass2026`. Kõik paroolid päritakse rangelt **Oracle Walletist (SEPS)** ja **Podman Secrets Store'ist**.

### 1.10 Konteinerite Pordi Isoleerimine (`127.0.0.1`)
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Kõik avaldatavad pordid (DB `1532`/`1533`, ORDS `8088`/`8448`, Publisher `9500`/`9502`/`9503`, Web IDE `8090`/`8449`) on seotud rangelt kohaliku liidesega (`127.0.0.1`), mis ennetab võrgulekkeid välisliidestele (`0.0.0.0`).

### 1.11 WebLogic REST API & Publisher HTTPS Reverse Proxy
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Loomine Nginx TLS 1.3 reverse proxy konfiguratsioon ([`config/nginx/publisher-ssl-proxy.conf`](../../config/nginx/publisher-ssl-proxy.conf)), mis suunab WebLogic AdminServeri (port `9500`) ja Publisher UI (port `9502`) turvalise HTTPS krüpteeringu kaudu.

### 1.12 Rootless Konteinerite Režiim & Privileegide Piiramine
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Lisatud `--security-opt=no-new-privileges` võti kõigile `podman run` käskudele ja compose generatorile, ennetades privileegide eskalatsiooni riske.

### 1.13 Artifactory ja Git Žetoonide Maskeerimine Logides
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Skript [`scripts/internal/sanitize-logs.sh`](../../scripts/internal/sanitize-logs.sh) teostab automaatse voo saniteerimise, mis asendab logides (`install_logs/*.log`) kõik tundlikud parameetrid tähisega `***MASKED***`.

### 1.14 Universaalne Reaalaegne Progress ja Puhverdamata Väljund
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Teostatud Option C hübriidne topeltvoo progressimuster (`print_step_progress`) koos unbuffered logifiltriga (`sed -u -E`), mis võimaldab reaalajas sekundite tiksumist brauseris ja terminalis, tagades samal ajal 100% puhtad ja loetavad logifailid ilma `\r` reostuseta.

### 1.16 LIS Süsteemi Üldine Põhiarhitektuur (4-Kihiline Mudel)
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Teostatud standardne enterprise 4-kihiline topoloogia (`db-publisher` metaandmed + `db-proxy` APEX/SSO vahekiht + `db-alise` isoleeritud äribaas + `app_ords` tsentraalne multi-pool ORDS server + `app_publisher` BI Publisher).

### 1.18 Paigalduse Ajakulu Optimeerimine (APEX DB Kiirendus 15m ➔ 1–2m)
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Viide Backlogile:** 📄 [`backlog/done/TASK-018-apex-install-speedup.md`](../../backlog/done/TASK-018-apex-install-speedup.md)
- **Realiseeritud 4-sambaline lahendus:** FastStart/Artifactory sise-konteineripildid, Golden Snapshot kiirtaastus (~30s), DB mälu ja PL/SQL kompilaatori tuunimine ja APEX Runtime režiim.

### 1.19 Analytics Publisheri & Multi-DB Paigalduse Kiirendus
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Viide Backlogile:** 📄 [`backlog/done/TASK-019-publisher-speedup.md`](../../backlog/done/TASK-019-publisher-speedup.md)
- **Realiseeritud lahendus:** Pre-built WebLogic domeenipilt, konfigureeritav paralleelsus ja domeeniehitaja utiliit.

### 1.20 Multi-DB SEPS Wallet ja TNS Joondus
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Viide Backlogile:** 📄 [`backlog/done/TASK-027-multi-db-seps-wallet-and-tns-alignment.md`](../../backlog/done/TASK-027-multi-db-seps-wallet-and-tns-alignment.md)
- **Kirjeldus:** Mitme andmebaasi paralleelsed SEPS rahakotid ja `tnsnames.ora` sünkroonne haldus.

### 1.21 VS Code Walleti Kõigi Kasutajate Sünkroniseerimine
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Viide Backlogile:** 📄 [`backlog/done/TASK-028-vscode-wallet-all-users-sync.md`](../../backlog/done/TASK-028-vscode-wallet-all-users-sync.md)

### 1.22 Oracle Forms 14c Konteiner ja noVNC Tugi
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Viide Backlogile:** 📄 [`backlog/done/TASK-029-oracle-forms-container-and-profiles.md`](../../backlog/done/TASK-029-oracle-forms-container-and-profiles.md)

### 1.23 Kanonilised Konteineriprefiksitega SEPS Walletid
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Viide Backlogile:** 📄 [`backlog/done/TASK-030-canonical-container-prefix-wallets.md`](../../backlog/done/TASK-030-canonical-container-prefix-wallets.md)

### 1.24 Terminali Progressi ja Ajakulu Kompaktne Kuvamine
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Viide Backlogile:** 📄 [`backlog/done/TASK-025-compact-terminal-ux.md`](../../backlog/done/TASK-025-compact-terminal-ux.md)

### 1.25 `setup-all.sh` Blueprintide Nimekirja ja Info CLI Parameetrid
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Viide Backlogile:** 📄 [`backlog/done/TASK-026-blueprint-cli-params.md`](../../backlog/done/TASK-026-blueprint-cli-params.md)

---

## 🔴 2. Realiseerimata ja Pooleli Olevad Tööd (Pending & Future Tasks)

### 2.1 Ametlike Ettevõtte TLS Sertifikaatide (PKI) Tugi
- **Staatus:** **❌ REALISEERIMATA / TEGEMATA**
- **Eesmärk:** Asendada lokaalne iseallkirjastatud test-sertifikaat (`localCA.pem`) ettevõtte PKI / Let's Encrypt sertifikaatidega toodangukeskkonnas.

### 2.2 Oracle Cloud (OCI) Kaug-Paigalduse ja Pilve-Tarne Reaalne Testimine
- **Staatus:** **🟡 OSALISELT REALISEERITUD**
- **Viide Backlogile:** 📄 [`backlog/todo/TASK-020-cloud-oci-deployment.md`](../../backlog/todo/TASK-020-cloud-oci-deployment.md)

### 2.3 Automaatne TDE (Transparent Data Encryption) Tugi ja Võtmehaldus
- **Staatus:** **🟡 OSALISELT REALISEERITUD**
- **Viide Backlogile:** 📄 [`backlog/todo/TASK-021-tde-encryption.md`](../../backlog/todo/TASK-021-tde-encryption.md)

### 2.4 Loetav Juurfailisüsteem ja Konteineri Rangem Hardening (`--read-only`)
- **Staatus:** **🟡 OSALISELT REALISEERITUD**
- **Viide Backlogile:** 📄 [`backlog/todo/TASK-022-readonly-hardening.md`](../../backlog/todo/TASK-022-readonly-hardening.md)

### 2.5 Keskne Auditilogi ja SIEM Integratsioon (Oracle Unified Auditing)
- **Staatus:** **❌ REALISEERIMATA / TEGEMATA**
- **Viide Backlogile:** 📄 [`backlog/todo/TASK-023-unified-auditing-siem.md`](../../backlog/todo/TASK-023-unified-auditing-siem.md)

### 2.6 WAF (Web Application Firewall) & OAuth2 / OIDC Entra-ID Integratsioon
- **Staatus:** **🟡 OSALISELT REALISEERITUD**
- **Viide Backlogile:** 📄 [`backlog/todo/TASK-024-waf-oauth2-entra-id.md`](../../backlog/todo/TASK-024-waf-oauth2-entra-id.md)
