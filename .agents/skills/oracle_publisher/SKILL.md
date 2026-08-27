---
name: oracle_publisher_devops
description: Juhised Oracle Analytics Publisher (Pixel Perfect / BI Publisher) kohalikuks paigaldamiseks, profiilide juhtimiseks, automaatseks patchimiseks ning REST API pragmatiatest (Report Execution, Catalog Management, Data Models).
---

# Oracle Analytics Publisher (Pixel Perfect): Paigaldus, REST API & DevOps Automatisatsioon

See skill juhendab, kuidas kasutada **Oracle Analytics Publisher (Pixel Perfect / BI Publisher)** teenust meie profiilipõhises DevOps keskkonnas. Skill koondab paigaldusjuhised, kahekäivituse (Podman vs Natiivne VM) loogika, automaatse OPatch patchimise ning **Oracle Analytics Publisher REST API (OAP REST API)** pragmatiad aruannete/trükiste automaatseks haldamiseks ja käivitamiseks.

---

## 1. Arhitektuur, Profiilid ja Litsentsireeglid

Analytics Publisher on integreeritud meie profiilipõhisesse süsteemi (`config/profiles/databases/publisher-only.yaml` ja `publisher-free.yaml`):

| Komponent | Port (HTTP / HTTPS) | Kirjeldus |
| :--- | :--- | :--- |
| **Publisher UI / REST API** | `9502` / `9503` | Analytics Publisher (Pixel Perfect) veebiliides (`/xmlpserver`) ja REST API (`/xmlpserver/services/rest/v1`). |
| **WebLogic Console** | `9500` / `9501` | WebLogic AdminServer haldusliides (`/console`). |
| **Publisher DB (`db-publisher`)** | `1533` | Andmebaas RCU skeemidega (`OAS_STB`, `OAS_CONFIG`, `OAS_IA`, `OAS_BIPLATFORM`, `OAS_OPSS`). |
| **ORDS REST (`ords-publisher`)** | `8089` / `8449` | SQL Developer Web (`_sdw`) liides Publisher andmebaasi ja ressursside brauseripõhiseks haldamiseks. |

---

### ⚠️ Krüptilised Õppetunnid ja DevOps Reeglid (Tuleviku Tõrgete Ennetamine)

1. **`publisher-only` Profiil ja Litsentsi Piirangud (`CONFIGURE_BIEE=false`)**:
   - Ettevõtetes ja keskkondades, kus on aktiivne **AINULT Oracle Analytics Publisheri (Pixel Perfect)** litsents ilma Full Analytics Server (BIEE / OBIEE) litsentsita, tuleb vaikehäälestuses ALATI määrata:
     - `CONFIGURE_BIEE=false`
     - `CONFIGURE_BIP=true`
   - **Eelised ja Stabiilsus:**
     - Vähendab paigaldussammude arvu 14-lt raskelt sammult **10-le puhtale Analytics Publisher sammule**:  
       `[Create default domains dir, Create expanded domain, Oracle Analytics Publisher, Complete domain, Store port range, Sync mid tier database, Add default service instance, Store JMS credential, Start all Servers, Collect logs]`.
     - Jätab vahele tarbetu ja mahuka Full BIEE `ee.bar` (Enterprise Edition BAR arhiivifaili) impordi, mis võib ilma BIEE litsentsita või piiratud mäluga keskkondades katkeda veaga `UnexpectedBarImportException`.

2. **ARM64 / macOS OpenSSL Wrapper & Java `keytool -gencert` CSR Allkirjastamine**:
   - ARM64 macOS ja Linux VM keskkondades asendab FMW installer OpenSSL-i `/u01/oracle/bi/modules/oracle.bi.openssl/bin/openssl` wrapperiga. Sertifikaatide ja võtmete loomisel tuleb rakendada **4 kohustuslikku reeglit**:
     1. **`keytool -gencert` CSR allkirjastamine:** Kui installer sooritab CSR päringu allkirjastamist (`openssl ca -infiles *.txt`), tuleb kasutada Java `keytool -gencert` utiliiti (`keytool -gencert -infile "$in_file" -outfile "$arg" -alias demoCA -keystore /tmp/demoCA.jks -storepass password -rfc`), mis eraldab CSR päringust tegeliku avaliku võtme. Nõnda klapib allkirjastatud sertifikaadi avalik võti Oracle Walleti privaatvõtmega 100%.
     2. **Mitte-tühja sertifikaadi varulahendus (Fallback):** Kui `keytool -gencert` ei saa sisendiks kehtivat CSR päringut, rakendatakse automaatne varulahendus `keytool -exportcert -alias demoCA -keystore /tmp/demoCA.jks -storepass password -rfc > "$arg"`. See tagab, et ükski genereeritud sertifikaadifail (sh `servercert.pem`) ei jää 0-baidiseks ega katkesta paigaldust veaga `resultFile ... empty`.
     3. **Kahe väljundparameetri loomine (`-keyout` ja `-out`):** OpenSSL wrapper peab ühe käigu raames genereerima MÕLEMAD nõutud failid (`cakey.pem` ja `cacert.pem`).
     4. **Binaarne DER kodeering (`.der` failid):** Laiendiga `.der` võtme-/sertifikaadifailid tuleb väljastada binaarbaiditena (`base64 -d`), ennetades ASCII PEM teksti sattumist binaarfaili.

3. **Mäluhaldus ja OOM Killer Kaitse (Podman VM)**:
   - Domeeni ehitamine (RCU + WLST + Publisher Domain) vajab Linux kernelis vähemalt **3–4 GB vaba operatiivmälu (RAM)**.
   - Enne paigaldusskripti käivitamist tuleb taustal olevad mitte-kriitilised konteinerid peatada (`podman stop app-db ords-dev-oracle-latest oracle-ords-publisher`), et välistada operatsioonisüsteemi mälutapja (`471 Killed` / `OOM Killer`) sekkumine.

4. **Puhas RCU Skeemide Taastamine**:
   - Veasituatsioonis ei tohi andmebaasist kustutada pelgalt üksikuid tabeliridu (nagu `JPS_DN`), vaid tuleb teostada kas täielik `DROP USER OAS_% CASCADE` koos puhaste repositooriumi skeemide uuesti loomisega (`rcu -createRepository`) või säilitada RCU poolt loodud algsed tabelikirjed.

5. **WebLogic Server 14.1.2.0.0 Ametlikud Halduskanalid**:
   - **Tähtis Muudatus:** Alates versioonist WebLogic Server 14.1.2.0.0 on sisse-ehitatud veebikonsool (`/console/`) eemaldatud.
   - **Ametlikud ja Turvalised Halduskanalid Ettevõtetes:**
     1. **Analytics Publisher Web UI (`http://localhost:9502/xmlpserver`):** Aruannete, mallide, andmeallikate (Data Sources), kasutajate ja trükiste ametlik brauseriliides (töötab 100% brauseris ilma lisatarkvarata).
     2. **WebLogic REST Management API (`http://localhost:9500/management/weblogic/latest/domainRuntime`):** Ametlik standardne REST liides serverite ja domeeni jälgimiseks `curl` või automaatskriptidega. Käivituskript `createAndStartDomain.sh` laadib automaatselt ametliku `console-rest-ext.war` laienduse.
     3. **WLST Skriptimine (`wlst.sh`):** Konteinerisisene ametlik Oracle WebLogic Scripting Tool domeeni ja serverite konfigureerimiseks.
     4. **Ametlik Oracle WebLogic Remote Console (Ametlik GitHub/Oracle tarkvara):**  
        - 📘 [Oracle WebLogic Remote Console Guide](https://docs.oracle.com/en/middleware/fusion-middleware/weblogic-remote-console/)
        - 🐙 [Official Oracle GitHub Repository](https://github.com/oracle/weblogic-remote-console)

---

## 2. Käivituse ja Paigalduse Skriptid

| Skript | Kirjeldus |
| :--- | :--- |
| **`./scripts/internal/download-publisher-binary.sh`** | Laadib automaatselt `V1055080-01.zip` / `V1045135-01.zip` (ettevõtte Artifactory peegeldusest `PUBLISHER_BINARY_URL` või eDelivery žetooniga `PUBLISHER_DOWNLOAD_TOKEN`). |
| **`./docker/publisher/build-publisher-image.sh`** | Ehitab kohaliku konteineri pildi `oracle/analyticsserver:2025` repositooriumi mallidest. |
| **`./scripts/install-publisher.sh`** | Algseadistab RCU skeemid (`init-publisher-rcu.sh`), ORDS liidesed ja käivitab Publisheri (toetab `PUBLISHER_INSTALL_MODE=container` või `native`). |
| **`./scripts/apply-publisher-patch.sh`** | Otsib kaustast `patches/` OPatch zip pakette (nt `p39179920_publisher.zip`) ja rakendab need automaatselt. |
| **`./scripts/internal/status-publisher.sh`** | Kontrollib WebLogic AdminServeri, Managed Serveri (`bi_server1`), Publisher UI (9502) ja DB ühenduse reaalset olekut. |
| **`./scripts/internal/restart-publisher.sh`** | Taaskäivitab WebLogic AdminServeri ja Publisher Serveri puhtalt ilma kogu konteinerit hävitamata. |
| **`./scripts/internal/backup-publisher-catalog.sh`** | Pakib ja varundab Publisheri aruannete mallid ja kataloogi arhiivina `backups/publisher_catalog_YYYYMMDD_HHMMSS.tar.gz`. |
| **`./scripts/internal/test-publisher-ds.sh`** | Kontrollib Publisher REST API ning `FREEPDB1` target andmebaasi olekut. |
| **`./scripts/internal/deploy-publisher-reports.sh`** | Sünkroniseerib eraldiseisva Giti repositooriumi (`PUBLISHER_REPORTS_GIT_URL`) ja paigaldab kasutaja aruanded/trükised Publisheri serverisse. |
| **`./scripts/deploy-remote.sh`** | Automaatne paigaldus lokaalsest arvutist või CI/CD liinist kaug-Linux pilveserverisse (OCI Always Free / Azure) üle SSH. |

### ☁️ Pilve- ja Kaugpaigaldus (OCI Always Free & GitHub Actions)

Kogu platvormi paigaldamiseks OCI Always Free (Ampere A1 ARM64 4 OCPU / 24GB RAM) või Azure Linux virtuaalmasinasse:
```bash
# 1. Kaugpaigaldus otse käsurealt lokaalsest arvutist:
./scripts/deploy-remote.sh --host 130.61.x.x --user opc --key ~/.ssh/id_ed25519 --profile publisher-only

# 2. GitHub Actions CI/CD töövoog:
# .github/workflows/deploy-remote-cloud.yml (kasutab secrets: REMOTE_HOST, REMOTE_USER, REMOTE_SSH_KEY)
```
*(Täpsem juhend: [docs/cloud-remote-deployment.md](../../../docs/cloud-remote-deployment.md))*

### 📦 Eraldiseisva Aruannete Repositooriumi Haldus (Git & Artifactory)

Äriaruannete ja trükiste disainerid saavad hoida oma mudeleid (`.xdm`) ja malle (`.xdo` / `.rtf`) kas eraldi Giti repositooriumis või laadida valmis valmis ehituspaketi (build artifact) etteõtte Artifactory'st:

```bash
# Variant A: Artifactory valmis ehituspakett (.zip / .tar.gz):
PUBLISHER_REPORTS_ARTIFACTORY_URL=https://artifactory.corp.internal/artifactory/generic-release/publisher-reports-latest.zip
ARTIFACTORY_TOKEN=my-artifactory-api-token

# Variant B: Eraldiseisev Giti repositoorium:
PUBLISHER_REPORTS_GIT_URL=https://github.com/my-org/oracle-publisher-reports.git
PUBLISHER_REPORTS_GIT_BRANCH=main

#### 🔀 Prioriteetide Järjekord Skriptis (`deploy-publisher-reports.sh`)
Kui määratud on mitu allikat, valib skript automaatselt kõige turvalisema allika:
1. 🥇 **Artifactory (`PUBLISHER_REPORTS_ARTIFACTORY_URL`):** *(Kõrgeim)* Laadib alla CI/CD poolt ehitatud ametliku release paketi.
2. 🥈 **Git Repositoorium (`PUBLISHER_REPORTS_GIT_URL`):** Tõmbab uued koodifailid eraldi Giti hoidlast.
3. 🥉 **Lokaalne Kaust (`publisher-reports/`):** Kasutab kohalikku kaustat.

---

### 💡 Natiivse Paigalduse Lüliti Peaskriptis (`setup-all.sh`)

Kui soovid peaskripti `./scripts/setup-all.sh` abil käivitada natiivse paigalduse otse Linux operatsioonisüsteemi (ilma konteinerita):
```bash
# Lülita peaskript natiivrežiimile
PUBLISHER_INSTALL_MODE=native ./scripts/setup-all.sh -y
```
*(Või määra kohalikus `.env` failis muutuja `PUBLISHER_INSTALL_MODE=native`)*

---

## 3. Oracle Analytics Publisher REST API (OAP REST API)

Ametlik Oracle dokumentatsioon: [Oracle Analytics Server REST API Endpoints](https://docs.oracle.com/en/middleware/bi/analytics-server/oap_rest_api/rest-endpoints.html)

**Baas-URL:**
- HTTP: `http://localhost:9502/xmlpserver/services/rest/v1`
- HTTPS: `https://localhost:9503/xmlpserver/services/rest/v1`

---

### 3.1 Aruannete Käivitamine ja PDF/Excel Trükiste Genereerimine

#### 1. Sünkroonne Aruande Käivitamine (`POST /reports/{reportPath}/run`)
Käivitab aruande ja tagastab otse valmis trükise (PDF, XLSX, HTML või XML):

```bash
# Näide: Arve PDF trükise genereerimine
PUBLISHER_PWD=$("./scripts/internal/get-password.sh" "DB_PUBLISHER_SYS" | grep "Password:" | awk '{print $3}')

curl -s -u weblogic:"${PUBLISHER_PWD}" \
  -H "Content-Type: application/json" \
  -X POST "http://localhost:9502/xmlpserver/services/rest/v1/reports/Guest%2FInvoices%2FInvoice_Report.xdo/run" \
  -d '{
    "attributeFormat": "pdf",
    "attributeLocale": "et-EE",
    "parameterNameValues": {
      "listOfParamNameValues": [
        {"name": "P_INVOICE_ID", "values": ["10045"]}
      ]
    }
  }' \
  --output invoice_10045.pdf
```

#### 2. Asünkroonne Trükise Töö Esitamine (`POST /jobs`)
Esitab mahuka trükise taustatööna:

```bash
curl -s -u weblogic:"${PUBLISHER_PWD}" \
  -H "Content-Type: application/json" \
  -X POST "http://localhost:9502/xmlpserver/services/rest/v1/jobs" \
  -d '{
    "jobName": "Monthly_Sales_Report_Job",
    "reportPath": "/Guest/Reports/Sales_Monthly.xdo",
    "userJobName": "Monthly Sales - Aug 2026",
    "saveDataOption": true
  }'
```

---

### 3.2 Katalogi ja Aruannete Haldus (Catalog REST API)

#### 1. Uue Aruande / Malli Üleslaadimine Kataloogi (`POST /reports`)
Laadib uue trükise malli (`.xdoz` / `.xdo`) automaatselt kataloogi:

```bash
curl -s -u weblogic:"${PUBLISHER_PWD}" \
  -H "Content-Type: multipart/form-data" \
  -X POST "http://localhost:9502/xmlpserver/services/rest/v1/reports" \
  -F "reportPath=/Guest/Invoices/New_Invoice_Report.xdo" \
  -F "file=@New_Invoice_Report.xdoz"
```

#### 2. Olemasoleva Aruande Definitisiooni Pärimine (`GET /reports/{reportPath}`)
```bash
curl -s -u weblogic:"${PUBLISHER_PWD}" \
  -H "Accept: application/json" \
  -X GET "http://localhost:9502/xmlpserver/services/rest/v1/reports/Guest%2FInvoices%2FInvoice_Report.xdo"
```

#### 3. Aruande Kustutamine Kataloogist (`DELETE /reports/{reportPath}`)
```bash
curl -s -u weblogic:"${PUBLISHER_PWD}" \
  -X DELETE "http://localhost:9502/xmlpserver/services/rest/v1/reports/Guest%2FInvoices%2FOld_Invoice_Report.xdo"
```

---

### 3.3 Andmeallikate (Data Sources) Haldus

#### Andmeallikate Nimekirja Pärimine (`GET /datasources`)
```bash
curl -s -u weblogic:"${PUBLISHER_PWD}" \
  -H "Accept: application/json" \
  -X GET "http://localhost:9502/xmlpserver/services/rest/v1/datasources"
```

---

## 4. Teadaolevad Tõrked ja Lahendused (Troubleshooting)

### 🚨 Kriitilised Vead WebLogici Taaskäivitusel

---

#### ❌ Tõrge: `EmbeddedLDAP — AssertionError: Assertion violated` → Server tapab ise ennast

**Sümptomid:**

```
CRITICAL: <WebLogicServer> <BEA-000386> <Server subsystem failed. Reason: A MultiException has 2 exceptions.
1. java.lang.AssertionError: Assertion violated
2. java.lang.IllegalStateException: Unable to perform operation: post construct on weblogic.ldap.EmbeddedLDAP

<WebLogicServer> <BEA-000365> <Server state changed to FAILED.>
<WebLogicServer> <BEA-000383> <A critical service failed. The server will shut itself down.>
Server state changed to FORCE_SHUTTING_DOWN
shutDownStatus=255
```

**Juurpõhjus:**

WebLogic salvestab domeeni loomisel `config/config.xml`-i `<listen-address>` väljale **konteineri loomise-aegse hostname** (s.o. konteineri ID, nt `0ae531d8db05`). Iga kord, kui konteiner hävitatakse ja taaskäivitatakse, saab see **uue container ID = uue hostname**. `EmbeddedLDAP` üritab seejärel leida vana nime järgi LDAP kanalit ja ebaõnnestub täielikult:

```xml
<!-- config.xml — probleem: hostname on konteineri ID, mitte staatiline aadress -->
<listen-address>0ae531d8db05</listen-address>
```

**Domeen luuakse ainult üks kord** (kontrollitakse `domainCheckFile` olemasolu). Igal järgneval käivitusel kasutatakse vana domeeni, kus on vale hostname — seega crash kordub garanteeritult.

**Kontrollkäsk (tõrke tuvastamine):**
```bash
podman exec oracle-publisher-dev /bin/bash -c \
  'PATH="/usr/bin:/bin:$PATH" sed -n "/<listen-address>/p" \
   /u01/oracle/user_projects/domains/bi/config/config.xml'
# Kui väljund sisaldab konteineri ID-d (hex string), on see tõrke allikas.
```

**Lahendus 1 (Soovitatav — kiireim):** Tühjenda `listen-address` iga käivituse alguses `createAndStartDomain.sh`-s:

```bash
# Lisa enne startWebLogic.sh käivitamist:
sed -i 's|<listen-address>[^<]*</listen-address>|<listen-address></listen-address>|g' \
  "${DOMAIN_HOME}/config/config.xml"
```

Tühi `<listen-address/>` = WebLogic kuulab **kõigil liidestele** (0.0.0.0) — staatiline ja restart-kindel.

**Lahendus 2 (Stabiilsus):** Määra konteinerile fikseeritud hostname `docker-compose.yml`-is:

```yaml
services:
  oracle-publisher-dev:
    hostname: publisher-dev   # ← alati sama, ei muutu restartidega
```

**Lahendus 3 (Drakooniline — väldi):** Kustuta domeen ja loo uuesti (`rm domainCheckFile`) — võtab **10–15 minutit** iga kord.

> [!IMPORTANT]
> **Lahendus 1 + 2 kombinatsioon** on parim valik: `sed` käsk `createAndStartDomain.sh`-s tagab, et isegi olemasoleva vale domeeni korral saab WebLogic korrektselt käivituda, ning `hostname: publisher-dev` tagab, et tulevikus loodud domeenid on kohe staatiline hostnimega.

---

#### ❌ Tõrge: `HTTP 000` / Publisher UI ei vasta (kuigi konteiner on üleval)

**Juurpõhjus:** WebLogic AdminServer käivitub ~3-5 minutiga, kuid Publisher Managed Server (`bi_server1`) vajab **täiendavalt 3-8 minutit** (JMS seadistus, BI komponentide initsialiseerimine). Seega `setup-all.sh` lõppkontroll näeb `HTTP 000`, kuid süsteem on tegelikult korras — lihtsalt mitte veel valmis.

**Tuvastamine:**
```bash
# Kontrolli protsesse konteineris (AdminServer vs bi_server1)
podman exec oracle-publisher-dev /bin/bash -c 'PATH="/usr/bin:/bin:$PATH" ps -ef'
# Kui mõlemad java protsessid on nähtaval, on käivitumine käimas
# Kui ainult tail/bash on alles → EmbeddedLDAP crash (vt eelmine tõrge)

# Kiire olek:
curl -s -I -m 10 http://localhost:9500/console  # AdminServer (valmis 1. järjekorras)
curl -s -I -m 10 http://localhost:9502/xmlpserver  # Publisher (valmis 2. järjekorras)
```

**Lahendus:** Oota täielikku käivitumist. `setup-all.sh` URL-kontroll tuleb pikendada vähemalt **12 minutile** (720 sekundit).

---

### 4.3 `bi_server1` Viga: `401 Unauthorized` või Puuduv `boot.properties`
**Sümptom:** WebLogic Console töötab (`http://localhost:9500/console`), aga Publisher UI (`http://localhost:9502/xmlpserver`) ei vasta ning logis kuvatakse `Could not register with the Administration Server: 401 Unauthorized`.

**Põhjus:** WebLogic Managed Server (`bi_server1`) üritab registreeruda AdminServeri juures, kuid vajab selleks `username=weblogic` ja `password=...` autentimisrekvisiite failis `boot.properties`. Ilma selle failita ei saa `startManagedWebLogic.sh` automaatselt autentida.

**Lahendus:** Tagada, et `createAndStartDomain.sh` loob enne AdminServeri ja Managed Serveri käivitamist failid:
- `${DOMAIN_HOME}/servers/AdminServer/security/boot.properties`
- `${DOMAIN_HOME}/servers/bi_server1/security/boot.properties`

```bash
mkdir -p "${DOMAIN_HOME}/servers/AdminServer/security" "${DOMAIN_HOME}/servers/bi_server1/security"
cat <<EOF > "${DOMAIN_HOME}/servers/bi_server1/security/boot.properties"
username=${ADMIN_USERNAME:-weblogic}
password=${ADMIN_PASSWORD:-Welcome123}
EOF
```

---

## 5. Testimine ja Silumine (Logid)

- **Paigalduse logi:** `install_logs/publisher_install_*.log`
- **Patchimise logi:** `install_logs/publisher_patch_*.log`
- **Ajamõõdikud:** `metrics/setup_benchmarks.json`
- **Automaattestid:** `./tests/unit/test-script-install-publisher.sh` ja `./tests/test-all-components.sh`

### 🔑 Ettevõtte Litsentsid (Enterprise Licenses) & OTN Tingimused

Tarkvara allalaadimiseks, paigaldamiseks ja kasutamiseks kehtivad järgmised tingimused:
1. **Äriline / Toodanguline Kasutus:** Vajab soetatud ametlikku litsentsi:
   - Oracle Analytics Publisher for Oracle Applications or OBI Publisher for Oracle Applications
   - **Oracle Analytics Publisher or Oracle Business Intelligence Publisher** *(Ettevõttes aktiivne litsents)*
   - Oracle Analytics Server Administrator or Oracle Business Intelligence Server Administrator
2. **Skriptide Õigused:** Repositooriumi skriptid ei anna ega asenda tarkvara kasutusõigust/litsentsi.
3. **POC ja Õppeotstarbeline Kasutus:** Prooviprojektide (POC) raames kehtib [Oracle Technology Network (OTN) License Agreement](https://www.oracle.com/downloads/licenses/standard-license.html), mis lubab allalaadimist ja piiratud kasutusõigust üksnes prototüüpimiseks ja õppimiseks, kuid **keelab kommettsiaalse/toodangulise kasutuse ilma soetatud litsentsita**.

---

## 6. Kasulikud Viited & Videoõpetused (Useful Resources)

- ⬇️ **Vajalikud Tarkvara Allalaadimise Lingid (Software Downloads):**
  - ☕ **Java JDK Allalaadimine:** [Oracle Java Downloads](https://www.oracle.com/java/technologies/downloads/)
  - 🏢 **Fusion Middleware / WebLogic Server Allalaadimine:** [Oracle WebLogic Server & FMW Installers](https://www.oracle.com/middleware/technologies/weblogic-server-installers-downloads.html)
  - 📊 **Analytics Publisher Allalaadimine:** [Oracle Software Delivery Cloud (eDelivery)](https://edelivery.oracle.com/osdc/faces/SoftwareDelivery)

### 📦 Oracle eDelivery Pakettide Kontrollsummad (Checksums & Files)

| Paketi Nimi | Faili Nimi | Suurus | SHA-256 Kontrollsumma |
| :--- | :--- | :--- | :--- |
| **Oracle Analytics Server 26.01.0.0.0 for Linux x86-64** | `V1055080-01.zip` (`Oracle_Analytics_Server_2026_Linux`) | 4.2 GB | `A71C69A4CB0360B1D70AB26559018DD1487C37F5BA28F5DA3EF924D9B351B711` |
| **Oracle Fusion Middleware 14c (14.1.2.0.0) Infrastructure** | `V1045135-01.zip` | 2.1 GB | `1AAE35167BDED101E7194AA3D75C26B292010035A36C289A3F90B663D84E68BD` |

- 🎥 **YouTube Koolitus / Video Tutorial:** [Developer Coaching - Pixel-Perfect Printing in Oracle APEX with Analytics Publisher](https://www.youtube.com/watch?v=EyJ_fjzFy3s&t=28s)
- 📕 **Ametlik Täielik Kasutusjuhend (PDF):** [Using Oracle Analytics Publisher in Oracle Analytics Server (PDF)](https://docs.oracle.com/en/middleware/bi/analytics-server/user-publisher-oas/using-oracle-analytics-publisher-oracle-analytics-server.pdf)
- 🏗️ **Oracle Fusion Middleware 14.1.2 Infrastruktuuri Juhend:** [Oracle Fusion Middleware 14.1.2 Download, Installation, and Configuration Readme](https://docs.oracle.com/en/middleware/fusion-middleware/14.1.2/mstrd/download-installation-and-configuration-readme.html)
- 📦 **Ametlik Paigalduse Peatükk:** [Installing the Oracle Analytics Server Software](https://docs.oracle.com/en/middleware/bi/analytics-server/install-config-oas/installing-product-software.html#GUID-D5AFD830-8A7D-42CC-8C22-CE68C452CF4A)
- ⚙️ **Ametlik Paigaldusjuhend (Silent Mode):** [Installing Oracle Analytics Server Software in Silent Mode](https://docs.oracle.com/en/middleware/bi/analytics-server/install-config-oas/oracle-analytics-server-installation.html#GUID-FA987D32-0E3B-40AF-AB81-2196F823C667)
- 📖 **Ametlik REST API Dokumentatsioon:** [Oracle Analytics Server REST API Endpoints](https://docs.oracle.com/en/middleware/bi/analytics-server/oap_rest_api/rest-endpoints.html)
- 📘 **Ametlik Raportite Loogika & Disaini Juhend:** [Create Pixel-Perfect Reports in Oracle Analytics Server](https://docs.oracle.com/en/middleware/bi/analytics-server/create-pixel-perfect-reports.html)
- 📜 **Ametlik Pixel-Perfect Raportite Ülevaade:** [Introduction to Pixel-Perfect Publishing](https://docs.oracle.com/en/middleware/bi/analytics-server/user-publisher-oas/introduction-pixel-perfect-publishing.html)
- 💻 **Töölaua Tööriistade Allalaadimise Juhend (Template Builder for Word/Excel):** [Download Desktop Tools for Publisher](https://docs.oracle.com/en/middleware/bi/analytics-server/user-publisher-oas/download-desktop-tools.html)

