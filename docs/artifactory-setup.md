# 🏢 Ettevõtte Artifactory Hoidla, Konteineriregister ja Semantiline Nimetamine

Tulemüüriga piiratud, suletud võrguga (*air-gapped*) või rangete turvanõuetega ettevõtte keskkonnas võimaldab platvorm suunata nii binaarpaketid (ORDS ja APEX `.zip` failid) kui ka **kõik konteineripildid** (*Docker/Podman images*) ettevõtte sisesesse **JFrog Artifactory**, **Harbor**, **Nexus** või **GitLab Container Registry** hoidlasse.

---

## 🎯 1. Peamised Eelised Ettevõtte Keskkonnas

1. **🚀 10x Kiirem Paigaldus:** 4 GB andmebaasipildi allalaadimine sisevõrgu LAN-ist võtab 10–20 sekundit (avalikust internetist 5–15 min).
2. **⚡ FastStart / Eelkompileeritud APEX Piltide Jagamine (TASK-018):** Ettevõte saab ehitada ühtse pildi `oracle-free-apex:23ai-apex26.1`, kus APEX on juba sees $\rightarrow$ andmebaas on püsti **30 sekundiga** ilma iga kord 15 minutit kompileerimata.
3. **🔒 Tulemüüride ja Suletud Võrkude Tugi:** Töötab täielikult ilma otsese internetiühenduseta.
4. **🛡️ Automaatne CVE Turvaskänneerimine:** JFrog Xray / Harbor Trivy skaneerib baasteegid enne toodangusse jõudmist.
5. **🛑 Docker Hub Rate Limitite Vältimine:** Puuduvad allalaadimise piirangud ja väliste serverite katkestuste risk.

---

## 🏷️ 2. Konteineripiltide Semantiline Nimetamisstandard (Multi-Component Tag Pattern)

Kohandatud ja eelkonfigureeritud andmebaasipiltide (*pre-baked images*) sildistamisel järgitakse **mitmeosalist semantilist mustrit**, mis tagab täieliku auditeeritavuse:

$$\mathbf{\text{oracle-free-}\{\text{TÜÜP}\}\text{:}\{\text{DB\_VER}\}\text{[-allikas][-apex}\{\text{APEX\_VER}\}\text{][-ords}\{\text{ORDS\_VER}\}\text{]}}$$

### Standardnäited:
* `oracle-free-apex:23ai-apex26.1` $\rightarrow$ Oracle Free DB 23ai + APEX 26.1
* `oracle-free-full:23ai-apex26.1-ords26.2` $\rightarrow$ DB 23ai + APEX 26.1 + ORDS 26.2
* `oracle-free-apex:23ai-gvenzl-apex26.1` $\rightarrow$ Gerald Venzl FastStart baaspildil
* `oracle-free-apex:23ai-ocr-apex26.1` $\rightarrow$ Oracle ametlikul Container Registry (OCR) baaspildil
* `oracle-publisher-domain:2025-db23ai` $\rightarrow$ Analytics Publisher 2025 koos valmis WebLogic BI domeeniga (TASK-019)

---

## 🏗️ 3. Pildi Ehitamine ja Andmebaasisisene Automaatne Sildistamine (In-DB Auto-Tagging)

Skript [`docker/apex/build-apex-prebuilt-image.sh`](../docker/apex/build-apex-prebuilt-image.sh) loeb pärast APEX-i paigaldamist **otse andmebaasi sisevaadetest** (`v$instance`, `dba_registry`, `ords_metadata`) reaalsed paigaldatud versiooninumbrit ja koostab 100% täpse sildise automaatselt:

```bash
# Täisautomaatne ehitus (tuvastab DB 23ai ja APEX 26.1 otse andmebaasist):
./docker/apex/build-apex-prebuilt-image.sh
```

Väljund:
```text
   4. Tuvastan reaalajas andmebaasi sisevaadetest versioonid (In-DB Auto-Tagging)...
      ├── Tuvastatud DB:   23ai
      ├── Tuvastatud APEX: 26.1
      └── Genereeritud Tag: 23ai-apex26.1

✅ APEX Pildi Ehitamine Õnnestus!
   📦 Pilt:   localhost/oracle-free-apex:23ai-apex26.1
   🏷️  Sildis: 23ai-apex26.1
   🔗 Alias:  localhost/oracle-free-apex:latest
```

---

## 📦 4. Konteineripiltide Üleslaadimine Artifactorysse (`publish-image-to-artifactory.sh`)

Utiliit [`scripts/publish-image-to-artifactory.sh`](../scripts/publish-image-to-artifactory.sh) tagib ja laeb kohalikud või ehitatud pildid sise-Artifactorysse ning seadistab vajadusel `.env` faili:

### 4.1 Kuivkäivitus ja Kontroll (`--dry-run`)
```bash
./scripts/publish-image-to-artifactory.sh \
  --registry "artifactory.ettevote.ee/docker-local/oracle" \
  --image "oracle-free-apex:23ai-apex26.1" \
  --dry-run
```

### 4.2 Reaalne Üleslaadimine ja `.env` Konfiguratsiooni Sidumine
```bash
./scripts/publish-image-to-artifactory.sh \
  --registry "artifactory.ettevote.ee/docker-local/oracle" \
  --image "oracle-free-apex:23ai-apex26.1" \
  --user "jfrog_deployer" \
  --password "salajane_api_token" \
  --update-env
```

Võti `--update-env` lisab/uuendab failis `.env` automaatselt rea:
```bash
REGISTRY_PREFIX="artifactory.ettevote.ee/docker-local/oracle/"
```

---

## ⚙️ 5. Käsitsi `.env` Seadistamise Näidis

Kopeeri või muuda faili `.env`:

```bash
# ============================================================================
# ETTEVÕTTE ARTIFACTORY JA REGISTRI SEADISTUS
# ============================================================================

# 1. Konteineripiltide peegelduse eesliide (Container Registry Prefix):
REGISTRY_PREFIX="artifactory.ettevote.ee/docker-local/oracle/"

# 2. Artifactory tarkvara allalaadimise otselingid (.zip failid):
ORDS_URL="https://artifactory.ettevote.ee/artifactory/oracle-binaries/ords-latest.zip"
APEX_URL="https://artifactory.ettevote.ee/artifactory/oracle-binaries/apex-latest.zip"

# 3. Vajadusel Artifactory autentimistunnused (kasutaja:token):
# ARTIFACTORY_AUTH="jfrog_user:api_token_või_parool"
```

Kõik paigaldusskriptid (`setup-all.sh`, `install-ords-standalone.sh`, `install-apex.sh` ja `generate-compose-override.sh`) rakendavad neid väärtusi automaatselt.

---

## 🌐 6. Ametlikud Allalaadimise Otselingid (OTN Välisvõrgus)

Kui pääs välisvõrku on avatud, laevad skriptid vaikimisi failid alla Oracle ametlikest hoidlatest:

* **Ametlik ORDS allalaadimisportaal:** [Oracle ORDS Downloads](https://www.oracle.com/database/sqldeveloper/technologies/dbactions/download/)
* **Ametlik ORDS OTN otselink:** `https://download.oracle.com/otn_software/java/ords/ords-latest.zip`
* **Ametlik APEX allalaadimisportaal:** [Oracle APEX Downloads](https://apex.oracle.com/download/)
* **Ametlik APEX OTN otselink:** `https://download.oracle.com/otn_software/apex/apex-latest.zip`
