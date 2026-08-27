# 🛡️ Arenduskeskkonna Laiendamise ja Turvalisuse Tulevikukava & Audit (Future Plans)

> [!NOTE]
> **Tulevikuplaanid on reorganiseeritud modulaarseks Backlog süsteemiks:**
> Kõik üksikud ülesanded, detailne arhitektuur ja elutsükkel asuvad nüüd kaustas **[`backlog/`](../backlog/README.md)**:
> - 🟢 **Teostatud ülesanded:** [`backlog/done/`](../backlog/done/)
> - 🟡 **Ootel / Kavandatavad ülesanded:** [`backlog/todo/`](../backlog/todo/)
> - 📄 **Uue ülesande mall:** [`backlog/template.md`](../backlog/template.md)

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
| **1.18** | Paigalduse Ajakulu Optimeerimine (3 Varianti APEX DB-le) | **🟡 NÕUAB OTSUSTAMIST** | 3 arhitektuurilist lahendust paigalduse ajakulu vähendamiseks 15m -> 1-2m |
| **1.19** | Analytics Publisheri & Multi-DB Paigalduse Kiirendus (4 Varianti) | **🟡 NÕUAB OTSUSTAMIST** | 4 arhitektuurilist lahendust Publisheri ja 3-DB topoloogia kiirendamiseks |
| **4.2** | Logide & Diagnostikafailide Puhastamine (`clean-logs.sh`) | **✅ REALISEERITUD** | Skript `scripts/clean-logs.sh` loodud ja testitud |
| **5.1** | Ametlike Ettevõtte TLS Sertifikaatide (PKI) Tugi | **❌ REALISEERIMATA** | Kasutusel on kohalik iseallkirjastatud `localCA.pem` |
| **6.1** | OCI Always Free Pilvepaigalduse Reaalne Katse | **🟡 OSALISELT REALISEERITUD** | `deploy-remote.sh` valmis, pilve-test ootab sooritamist |
| **6.2** | GitHub Actions CI/CD Reaalne Pilve-Tarne | **🟡 OSALISELT REALISEERITUD** | `deploy-remote-cloud.yml` valmis, pilvesekreedid ootavad |
| **2.8** | Automaatne TDE (Transparent Data Encryption) Tugi | **🟡 OSALISELT REALISEERITUD** | Tablespace'ide AES-256 krüpteerimine kettal ja keystore võtid |
| **2.9** | Loetav Juurfailisüsteem ja Rangem Hardening (`--read-only`) | **🟡 OSALISELT REALISEERITUD** | Konteinerite juurfailisüsteemi lukustamine ja `tmpfs` |
| **2.10** | Keskne Auditilogi ja SIEM Integratsioon (Unified Auditing) | **❌ REALISEERIMATA** | Oracle Unified Auditing poliitikad ja logiforwarder |
| **2.11** | WAF & OAuth2 / OIDC Entra-ID Lõiming REST API-dele | **🟡 OSALISELT REALISEERITUD** | Nginx WAF / ModSecurity ja ORDS REST OAuth2 Bearer kaitse |
| **2.12** | Terminali Progressi ja Ajakulu Kompaktne Kuvamine | **🟡 PLAANIS (Disain)** | Töö edenemise näitamine ilma terminali ekraani risustamata ja skrollimiseta |
| **2.13** | Future Plans Reorganiseerimine Modulaarseks Backlogiks | **✅ REALISEERITUD** | Eraldi failid `backlog/todo/` ja `backlog/done/` kaustades |
| **2.14** | `setup-all.sh` Blueprintide Nimekirja ja Info CLI Parameetrid | **🟡 PLAANIS** | `--list-blueprints` (`-lb`), `--show-blueprint` (`-sb`), `--search-blueprints` |

---

## 🟢 1. Realiseeritud ja Valideeritud Funktsionaalsused (Completed Features)

### 1.1 Konteineriseeritud Arendusvahendid (VS Code + SQL Developer + Git jne)
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [docs/web-ide-artifactory.md](web-ide-artifactory.md)
- **Reaalne kontroll:** Kontrollitud `web-ide` profiil ja Dockerfile. Pildil on pre-installeeritud OpenJDK 21, Oracle SQLcl, Liquibase, Git, Python3, GitHub CLI (`gh`), `act` CLI ja VS Code laiendused (`Oracle.sql-developer-for-vscode`, `github.vscode-github-actions`). Brauseri kaudu ligipääsetav aadressil `http://localhost:8090`.

### 1.2 GitHub Actions / CI/CD Töövoog & Lokaalne Offline Testimine Podmanis
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [docs/github-actions-cicd.md](github-actions-cicd.md)
- **Reaalne kontroll:** SQLcl Projects automatiseerimine (`.dbtools/project.config.json`), lokaalne simulaator [`./scripts/test-local-ci.sh`](../scripts/test-local-ci.sh), Nektos `act` CLI ja VS Code laiendus `github.vscode-github-actions` on koodibaasis olemas ja funktsioneerivad.

### 1.3 Oracle Analytics Publisher (Pixel Perfect) Kohalik Käivitamine
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [docs/publisher-guide.md](publisher-guide.md)
- **Reaalne kontroll:** Paigaldus testitud ja verifitseeritud (`oracle/analyticsserver:2025`). Pordil `9502` tagastab `/xmlpserver/login.jsp` puhta **HTTP 200 OK** ning HTML tiitli `<title>Oracle Analytics Publisher Login</title>`.

### 1.4 VS Code Ühenduste Universaalne Registreerimine
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [connections/README.md](../connections/README.md)
- **Reaalne kontroll:** Registreerib VS Code Oracle SQL Developer laiendusele automaatselt ühendused ja kaustad: `/APEX` (Standard DB), `/MYATP` (ADB režiim) ja `/Publisher` (Publisher DB).

### 1.5 Ristplatvormne SSL Juursertifikaadi Automaatne Kontroll & Usaldamine
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Reaalne kontroll:** `setup-all.sh` ja `generate-local-certs.sh` kontrollivad ja usaldavad kohalikku HTTPS juursertifikaati (`config/certs/localCA.pem`) operatsioonisüsteemi sertifikaadihoidlas (macOS Keychain `security`, Windows `certutil`, WSL interop).

### 1.6 Dünaamiline YAML Andmebaasi Profiilide Mootor & Topoloogia Haldur
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [docs/db-profiles-and-topology.md](db-profiles-and-topology.md)
- **Reaalne kontroll:** 7 standardset YAML profiili (`config/profiles/*.yaml`), 3-tasemeline failide lahendamise ahel ning [resolve-topology.sh](../scripts/internal/resolve-topology.sh) portide ja mahutite konfliktide lahendamiseks.

### 1.7 Alamkomponentide & Kogu Süsteemi Automaattestimise Raamistik
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [tests/README.md](../tests/README.md)
- **Reaalne kontroll:** Modulaarne automaattestimise raamistik ([test-all-components.sh](../tests/test-all-components.sh) ja [test-e2e-system.sh](../tests/integration/test-e2e-system.sh)), mis kontrollib 0-käsitööga ORDS REST kontrolle, APEX mootorit, Walleti paroole ja SSL sertifikaate.

### 1.8 Logide & Diagnostikafailide Puhastamine (`clean-logs.sh`)
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Dokumentatsioon:** 📄 [scripts/README.md](../scripts/README.md)
- **Reaalne kontroll:** Skript [`./scripts/clean-logs.sh`](../scripts/clean-logs.sh) kustutab `install_logs/*.log` failid, `unzipped_log*` kataloogid ning `bieeconfiglogs*.zip` arhiivid. Läbis automaattesti `test-script-clean-logs.sh`.

### 1.9 Vaikimisi Varuparoolide Eemaldamine
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Eemaldatud kõigist skriptidest (`install-publisher.sh`, `init-publisher-rcu.sh`, `deploy-publisher-reports.sh`, `createAndStartDomain.sh`) kõvakodeeritud varuparoolid `OraclePass2026`. Kõik paroolid päritakse rangelt **Oracle Walletist (SEPS)** ja **Podman Secrets Store'ist**.

### 1.10 Konteinerite Pordi Isoleerimine (`127.0.0.1`)
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Kõik avaldatavad pordid (DB `1532`/`1533`, ORDS `8088`/`8448`, Publisher `9500`/`9502`/`9503`, Web IDE `8090`/`8449`) on seotud rangelt kohaliku liidesega (`127.0.0.1`), mis ennetab võrgulekkeid välisliidestele (`0.0.0.0`).

### 1.11 WebLogic REST API & Publisher HTTPS Reverse Proxy
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Loomine Nginx TLS 1.3 reverse proxy konfiguratsioon ([`config/nginx/publisher-ssl-proxy.conf`](../config/nginx/publisher-ssl-proxy.conf)), mis suunab WebLogic AdminServeri (port `9500`) ja Publisher UI (port `9502`) turvalise HTTPS krüpteeringu kaudu.

### 1.12 Rootless Konteinerite Režiim & Privileegide Piiramine
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Lisatud `--security-opt=no-new-privileges` võti kõigile `podman run` käskudele (`install-publisher.sh`, `run_sqlcl`, `create-golden-snapshots.sh`) ja compose override generatorile, ennetades konteinerist väljamurdmise riske.

### 1.13 Artifactory ja Git Žetoonide Maskeerimine Logides
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Skript [`scripts/internal/sanitize-logs.sh`](../scripts/internal/sanitize-logs.sh) teostab automaatse voo saniteerimise, mis asendab logides (`install_logs/*.log`) kõik `ACCESS_TOKEN`, `token=...`, `Authorization: Bearer ...` ja parooli väärtused tekstiga `***MASKED***`.
- **Erandkorras debugimine:** Kui tõrkeotsinguks on hädavajalik näha logides avatud žetoone või Bearer päringupäiseid, saab maskingut erandkorras ajutiselt välja lülitada keskkonnamuutujaga: `DEBUG_LOG_UNSANITIZED=true ./scripts/setup-all.sh`. Seda tuleb kasutada AINULT erandkorras ja lokaalses turvalises keskkonnas.

### 1.14 Universaalne Reaalaegne Progress ja Puhverdamata Väljund
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Teostatud Option C hübriidne topeltvoo progressimuster (`print_step_progress`) koos unbuffered logifiltriga (`sed -u -E`), mis võimaldab reaalajas sekundite tiksumist brauseris ja terminalis, tagades samal ajal 100% puhtad ja loetavad logifailid ilma `\r` reostuseta. Uuendatud on kõigi skriptide (`setup-all.sh`, `install-publisher.sh`, `create-golden-snapshots.sh`, `install-apex.sh`) pikemad ootesilmused.

### 1.16 LIS Süsteemi Üldine Põhiarhitektuur (4-Kihiline Mudel)
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Kirjeldus:** Teostatud standardne enterprise 4-kihiline topoloogia (`db-publisher` metaandmed + `db-proxy` APEX/SSO vahekiht + `db-lis` isoleeritud äribaas + `app_ords` tsentraalne multi-pool ORDS server + `app_publisher` BI Publisher). Tagatud on 0 outbound internet liikuvus `db-lis` ärisektoris ja Outbound REST ACL load `db-proxy` kihis.

### 1.17 Automaatne Versiooni Tuvastamine ja Eelinfo Õigepärasus (DB, APEX, ORDS)
- **Staatus:** **✅ REALISEERITUD JA VALIDEERITUD**
- **Arhitektuuriline põhimõte:** Käsitsi seadistamise ja eksitavate versiooninumbrite täielik välistamine. Kasutaja ei pea versioone käsitsi konfigureerima ega sisestama.
- **Kontrollimehhanism ja Reegel:**
  1. **Konteineri režiim (Container Mode):** Kui kasutusel on konteineri pilt (`RESOLVED_DB_IMAGE` või `PROFILE_ORDS_CONTAINER_IMAGE`), pärida versiooninfo otse konteineri pildilt / märgistest (`podman image inspect` sildid `com.oracle.database.version` / `org.opencontainers.image.version`) ja profiili YAML-ist, välistades käsitsi kõvakodeerimise.
  2. **Standalone režiim (Standalone Zip Package Mode):** Kui kasutatakse kohalikku / standalone zip-paketti (`binaries/ords/ords-*.zip` või `binaries/apex/apex_*.zip`), tuvastatakse versioon automaatselt otse arhiivifaili nimest ja tarkvara manifestist.
  3. **Väljund päises:** Enne paigalduse kinnitamist (`setup-all.sh`) kuvatav eelinfo tagab 100% õigepärasuse iga aktiivse andmebaasi ja ORDS/APEX komponendi kohta, vältides käsitsi seadistamist ja eksitusi.

### 1.18 Kogu Keskkonna (DB + APEX + ORDS + Analytics Publisher + Multi-DB) Paigalduse Kiirendamine (15-20 min ➔ 1–2 min)
- **Staatus:** **🟡 NÕUAB OTSUSTAMIST / ARHITEKTUURILINE VALIK**
- **Eesmärk:** Vähendada kogu keskkonna (3x Oracle Free DB + APEX 26.2 + ORDS + WebLogic Analytics Publisher) paigalduse ja ehituse ajakulu praeguselt **~15–20 minutilt alla 1–2 minuti**.
- **Põhjus & Diagnostika:** Praegusest ajakulust kulub ~16 minutit neljale mahukale sammule:
  1. Ametliku Oracle pildi esmakordne `CREATE DATABASE` / DBCA tekitamine nullist (~6 minutit).
  2. APEX mootori kompileerimine ja DDL skriptide täitmine host-masinast läbi SQLcl (~6 minutit).
  3. WebLogic RCU metaandmete skeemide (`OAS_*`) tekitamine metaandmete baasis `db-publisher` (~2 minutit).
  4. WebLogic BI domeeni ehitus ja WLST skriptide täitmine (`create_base_domain.py`) (~4 minutit).
- **4 Ühtset Arhitektuurilist Varianti (Vajab otsustamist, millist lahendust rakendada):**
  - **Variant A (Eel-konfigureeritud Immutatavad Konteineripildid - Pre-built APEX & Publisher Domain Images) [Soovitatud]:**  
    Ehitada/kasutada eelkonfigureeritud pilte (`oracle-free-apex:26.2` ja `oracle-publisher-domain-prebuilt:2025`), milles APEX 26.2, RCU skeemid ja WebLogic BI domeen (`/u01/oracle/user_projects/domains/bi`) on juba pildi sisse sisse ehitatud.  
    *Tulemus:* Paigaldamisel ei toimu enam ühtegi DBCA tekitamist, RCU skeemide loomist ega WLST domeeniskripte.  
    *Ajasääst:* ~16–18 minutit *(Kogu keskkonna tõstmine lüheneb **~1–2 minutile**!)*.
  - **Variant B (FastStart DB Pildimudelite Laialdane Kasutamine):**  
    Lülitada kõik andmebaasi profiilid (`db-publisher`, `db-proxy`, `db-lis`) pildile `docker.io/gvenzl/oracle-free:23-full-faststart`.  
    *Tulemus:* Andmebaasid ei tee DBCA tekitamist, vaid käivituvad koheselt mälus **10 sekundiga**.  
    *Ajasääst:* ~6 minutit *(Kogu paigaldus ~8–9 minutit)*.
  - **Variant C (Andmekannu Ketta-mahu / Volume & Domain Snapshot Caching):**  
    Esmakordsel paigaldusel salvestada WebLogic domeeni kaust ja metaandmete baaside ketta-mahud (*named volume snapshot / Golden Snapshot*), taastades selle uutel paigaldustel otse kettalt.  
    *Ajasääst:* ~10–12 minutit korduvpaigaldusel.
  - **Variant D (Nutikas Ressurssipõhine Paralleelne Orkestreerimine):**  
    Kui masinas on piisavalt RAM-i (≥ 8 GB), käivitada kõigi kolme andmebaasi (`db-publisher`, `db-proxy`, `db-lis`) ja Publisheri taustaprotsessid korraga mälus paralleelselt, hoides vähese mäluga masinatel automaatselt režiimi `STRICT_SEQUENTIAL_MODE=true`.

---

## 🔴 2. Realiseerimata ja Pooleli Olevad Tööd (Pending & Future Tasks)

### 2.6 Ametlike TLS Sertifikaatide Tugi
- **Staatus:** **❌ REALISEERIMATA / TEGEMATA**
- **Eesmärk:** Asendada iseallkirjastatud test-sertifikaadid ettevõtte PKI / Let's Encrypt sertifikaatidega.
- **Lahendus:** Lõimida automaatne sertifikaatide uuenemine ja usaldusahela (CA Chain) registreerimine Java Keystore'i.

### 2.7 Oracle Cloud (OCI) Kaug-Paigalduse ja Publisheri Testimiskava
- **Staatus:** **🟡 OSALISELT REALISEERITUD**
- **Eesmärk:** Teostada Analytics Publisheri, ORDS-i ja Oracle Free DB reaalne paigaldus ning jõudlustestimine Oracle Cloud Infrastructure (OCI) Always Free keskkonnas.
- **Lahendus:** Automaatskript [`./scripts/deploy-remote.sh`](../scripts/deploy-remote.sh) ja workflow [.github/workflows/deploy-remote-cloud.yml](../.github/workflows/deploy-remote-cloud.yml) on koodibaasis olemas, kuid ootavad reaalsete pilve-sekreetide ja pilveserveri katse läbiviimist.

### 2.8 Automaatne TDE (Transparent Data Encryption) Tugi ja Võtmehaldus
- **Staatus:** **🟡 OSALISELT REALISEERITUD**
- **Eesmärk:** Tagada, et toodangukeskkonnas oleksid `db-apex-proxy` ja `db-publisher` tabeliruumid (*tablespaces*) ning ketta undo/redo logid automaatselt krüpteeritud AES-256 võtmega.
- **Lahendus:** Täiendada `init-db-instance.sh` ja YAML profiile automaatse TDE keystore/walleti loogikaga (`ADMINISTER KEY MANAGEMENT SET KEY`), et tagada andmete krüpteeritus kettal.

### 2.9 Loetav Juurfailisüsteem ja Konteineri Rangem Hardening (`--read-only`)
- **Staatus:** **🟡 OSALISELT REALISEERITUD**
- **Eesmärk:** Tõsta toodangukonteinerite turvalisust rünnakute vastu, keelates konteineri juurfailisüsteemi muutmise (`--read-only`).
- **Lahendus:** Konfigureerida Podman käivitustele `--read-only` lipp ning suunata ajutised kirjutuskaustad (`/tmp`, `/var/run`, `/u01/container_state`) isoleeritud `tmpfs` või mälupuhvri alla.

### 2.10 Keskne Auditilogi ja SIEM Integratsioon (Oracle Unified Auditing)
- **Staatus:** **❌ REALISEERIMATA / TEGEMATA**
- **Eesmärk:** Automatiseerida Oracle Unified Auditing turvapoliitikate rakendamine ja logivoogude reaalajas edastamine kesksetesse SIEM süsteemidesse (Splunk, Elastic, Azure Sentinel).
- **Lahendus:** Luua `scripts/internal/init-unified-auditing.sql` ning logiforwarder (Vector / Fluentd / Logstash) konteineri profiil auditilogide turvaliseks edastamiseks.

### 2.11 WAF (Web Application Firewall) & OAuth2 / OIDC Entra-ID Integratsioon
- **Staatus:** **🟡 OSALISELT REALISEERITUD**
- **Eesmärk:** Kaitsta APEX REST API-sid ja ORDS-i OAuth2 Bearer žetoonidega (Azure Entra-ID / Identity Provider) ning WAF reeglitega enne päringute jõudmist andmebaasi.
- **Lahendus:** Täiendada Nginx proxy konfiguratsiooni WAF / ModSecurity kaitsega ning lisada ORDS REST OAuth2 automaatse registreerimise skriptid.

### 2.12 Terminali Reaalaaja Protsessi Progressi ja Ajakulu Kuvamise Kompaktne Disain
- **Staatus:** **🟡 PLAANIS / DISAIN (Nõuab otsustamist)**
- **Eesmärk:** Muuta pikemate sammude (nt APEX mootori kompileerimine ~6 min, Publisher konteineri ehitus ~8 min) jooksva aja ja progressi teavitused palju kompaktsemaks, et terminali ekraan ei täituks korduvate ridadega (`⏳ Paigaldan APEX mootorit... kestus: 15s`, `30s`, `45s`...), mis sunnivad kasutajat üles-alla skrollima.
- **Kasutaja vajadus & Eesmärk:** Kasutaja peab igal hetkel selgelt aru saama, et protsess liigub ja süsteem ei ole hangunud, samas peab tagasiside olema puhas, ühel real või minimaalse sammuga, säilitades terminali ülevaatlikkuse.
- **3 Võimalikku Disainilahendust / Varianti (Tuleb otsustada):**
  - **Variant A (Ühel real kohapeal uuenev TTY Progressiriba / Dynamic Inline Status) [Soovitatud interaktiivses kestades]:**  
    Kasutada kesta rea tühjendamist (`\r\033[K`), et trükkida uue rea asemel sama rea peale uuenev staatus koos progressiriba või spinneriga, nt:  
    `   ⏳ APEX mootori paigaldus käib... [████████░░░░] 3m 45s (keskmine ooteaeg 6m)`  
    *Eelis:* Terminali ei teki ühtegi üleliigset rida, kasutaja näeb jooksvalt aega ega pea skrollima.
  - **Variant B (Harv ja Kompaktne Teavitussamm - Logiva Keskkonna Mudel):**  
    Mittetaktilises/faili logivas keskkonnas vähendada vahe-ridade trükkimise sagedust (nt trükkida teavitus rida AINULT iga 2-3 minuti järel või olulise alamsammu muutumisel), nt:  
    `   [03:00 / ~06:00] ⏳ APEX mootori paigaldus käib sujuvalt...`  
    *Eelis:* Logifailid ja CI/CD terminalid jäävad ülimalt puhtaks ja ülevaatlikuks.
  - **Variant C (Tsentraalne Päis + Vahetu Tulemus):**  
    Kuvada sammu alguses selge päis eeldatava ajaga ning mitte prindida ühtegi vahe-rida, vaid väljastada tulemus vahetult sammu lõppedes koos tegeliku ajakuluga (`⏱ Samm 6 valmis: 5m 12s`).  
    *Eelis:* Kõige puhtam terminali väljund.

### 2.13 Future Plans Reorganiseerimine Modulaarseks Backlogiks (`backlog/`)
- **Staatus:** **✅ REALISEERITUD**
- **Eesmärk:** Asendada üksik pikk tulevikuplaanide fail modulaarse ja selgelt hallatava **Backlog süsteemiga**, kus igal arendusideel ja arhitektuursel täiendusel on oma spetsiifiline Markdown fail.
- **Kataloogi struktuur:**
  ```text
  backlog/
  ├── README.md               # Backlogi ülevaatemaatriks, reeglid ja indeks
  ├── todo/                   # Ootel / kavandatavad ideed ja ülesanded
  │   ├── TASK-018-*.md
  │   └── TASK-019-*.md
  └── done/                   # Teostatud ja valideeritud ülesanded
      ├── TASK-001-*.md
      └── ...
  ```
- **Elutsükkel & Automaatika:**
  - Iga uus idee luuakse mallipõhiselt kausta `backlog/todo/` (sisaldab probleemi kirjeldust, eesmärki, kavandatud lahendust, seoseid ja testimiskava).
  - Kui funktsionaalsus realiseeritakse ja testid läbivad 100%, liigutatakse fail kausta `backlog/done/`.
  - See tagab selge auditi ja versioonihalduse ajaloo iga funktsionaalsuse valmimise kohta.

### 2.14 `setup-all.sh` Blueprintide Nimekirja ja Info CLI Parameetrid
- **Staatus:** **🟡 PLAANIS (Kavandatud)**
- **Eesmärk:** Võimaldada kasutajal saada kohene ja mugav ülevaade kõigist 13 ametlikust arhitektuursest blueprintist otse terminalis ilma, et peaks käsitsi otsima või sirvima kataloogi `config/blueprints/`.
- **Kavandatud CLI parameetrid:**
  1. **`./scripts/setup-all.sh --list-blueprints` (lühivorm: `-lb` või `-l`):**
     - Kuvab terminalis värvilise ja struktureeritud tabeli kõigist 13 blueprintist:
       - **Nr:** [1–13]
       - **Blueprinti Nimi:** nt `.env.3-db-lis-apex-ords-with-proxy`
       - **Aktiivsed Teenused:** `db-proxy`, `db-lis`, `app-ords`
       - **Eesmärk / Kirjeldus:** 2-kihiline andmebaasi arhitektuur (Proxy + LIS)
       - **RAM Vajadus:** Hinnanguline mälumaht (nt `~4 GB`)
  2. **`./scripts/setup-all.sh --show-blueprint <N>` (lühivorm: `-sb <N>`):**
     - Kuvab konkreetse blueprinti detailse konfiguratsiooni: pordid, andmebaasi profiilid, APEX versioonid ja ORDS URL-id enne käivitamist.
  3. **`./scripts/setup-all.sh --search-blueprints <MÄRKSÕNA>`:**
     - Filtreerib ja kuvab ainult need blueprintid, mis sisaldavad otsitavat teenust või märksõna (nt `publisher`, `adb`, `gvenzl`, `web-ide`).
  4. **`./scripts/setup-all.sh -b <N> --dry-run`:**
     - Simuleerib käivitust ja kuvab eelinfo ilma tegelikku konteinerite allalaadimist või käivitamist alustamata.


