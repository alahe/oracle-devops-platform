---
name: oracle_publisher_devops
description: Juhised Oracle Analytics Publisher (Pixel Perfect / BI Publisher) kohalikuks paigaldamiseks, profiilide juhtimiseks, automaatseks patchimiseks ning REST API pragmatiatest (Report Execution, Catalog Management, Data Models).
---

# Oracle Analytics Publisher (Pixel Perfect): Paigaldus, REST API & DevOps Automatisatsioon

See skill juhendab, kuidas kasutada **Oracle Analytics Publisher (Pixel Perfect / BI Publisher)** teenust meie profiilipõhises DevOps keskkonnas. Skill koondab paigaldusjuhised, kahekäivituse (Podman vs Natiivne VM) loogika, automaatse OPatch patchimise ning **Oracle Analytics Publisher REST API (OAP REST API)** pragmatiad aruannete/trükiste automaatseks haldamiseks ja käivitamiseks.

---

## 1. Arhitektuur ja Profiilid

Analytics Publisher on integreeritud meie profiilipõhisesse süsteemi (`config/profiles/databases/publisher-free.yaml` ja `appinfra.yaml`):

| Komponent | Port (HTTP / HTTPS) | Kirjeldus |
| :--- | :--- | :--- |
| **Publisher UI / REST API** | `9502` / `9503` | Analytics Publisher (Pixel Perfect) veebiliides (`/xmlpserver`) ja REST API (`/xmlpserver/services/rest/v1`). |
| **Publisher DB (`db-publisher`)** | `1533` | Andmebaas RCU skeemidega (`OAS_STB`, `OAS_CONFIG`, `OAS_IA`). |
| **ORDS REST (`ords-publisher`)** | `8089` / `8449` | SQL Developer Web (`_sdw`) liides Publisher andmebaasi ja ressursside brauseripõhiseks haldamiseks. |

---

## 2. Käivituse ja Paigalduse Skriptid

| Skript | Kirjeldus |
| :--- | :--- |
| **`./docker/publisher/build-publisher-image.sh`** | Ehitab kohaliku konteineri pildi `oracle/analyticsserver:2025` repositooriumi mallidest. |
| **`./scripts/install-publisher.sh`** | Algseadistab RCU skeemid (`init-publisher-rcu.sh`), ORDS liidesed (`init-publisher-ords.sh`) ja käivitab Publisheri. |
| **`./scripts/apply-publisher-patch.sh`** | Otsib kaustast `patches/` OPatch zip pakette (nt `p39179920_publisher.zip`) ja rakendab need automaatselt. |

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
PUBLISHER_PWD=$("./scripts/internal/view-wallet-credential.sh" "DB_PUBLISHER_SYS" | grep "Password:" | awk '{print $3}')

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

## 4. Testimine ja Silumine

- **Paigalduse logi:** `install_logs/publisher_install_*.log`
- **Patchimise logi:** `install_logs/publisher_patch_*.log`
- **Ajamõõdikud:** `metrics/setup_benchmarks.json`
- **Automaattestid:** `./tests/unit/test-script-install-publisher.sh` ja `./tests/test-all-components.sh`

---

## 5. Kasulikud Viited & Videoõpetused (Useful Resources)

- 🎥 **YouTube Koolitus / Video Tutorial:** [Developer Coaching - Pixel-Perfect Printing in Oracle APEX with Analytics Publisher](https://www.youtube.com/watch?v=EyJ_fjzFy3s&t=28s)
- 📕 **Ametlik Täielik Kasutusjuhend (PDF):** [Using Oracle Analytics Publisher in Oracle Analytics Server (PDF)](https://docs.oracle.com/en/middleware/bi/analytics-server/user-publisher-oas/using-oracle-analytics-publisher-oracle-analytics-server.pdf)
- 🏗️ **Oracle Fusion Middleware 14.1.2 Infrastruktuuri Juhend:** [Oracle Fusion Middleware 14.1.2 Download, Installation, and Configuration Readme](https://docs.oracle.com/en/middleware/fusion-middleware/14.1.2/mstrd/download-installation-and-configuration-readme.html)
- 📦 **Ametlik Paigalduse Peatükk:** [Installing the Oracle Analytics Server Software](https://docs.oracle.com/en/middleware/bi/analytics-server/install-config-oas/installing-product-software.html#GUID-D5AFD830-8A7D-42CC-8C22-CE68C452CF4A)
- ⚙️ **Ametlik Paigaldusjuhend (Silent Mode):** [Installing Oracle Analytics Server Software in Silent Mode](https://docs.oracle.com/en/middleware/bi/analytics-server/install-config-oas/oracle-analytics-server-installation.html#GUID-FA987D32-0E3B-40AF-AB81-2196F823C667)
- 📖 **Ametlik REST API Dokumentatsioon:** [Oracle Analytics Server REST API Endpoints](https://docs.oracle.com/en/middleware/bi/analytics-server/oap_rest_api/rest-endpoints.html)
- 📘 **Ametlik Raportite Loogika & Disaini Juhend:** [Create Pixel-Perfect Reports in Oracle Analytics Server](https://docs.oracle.com/en/middleware/bi/analytics-server/create-pixel-perfect-reports.html)
- 📜 **Ametlik Pixel-Perfect Raportite Ülevaade:** [Introduction to Pixel-Perfect Publishing](https://docs.oracle.com/en/middleware/bi/analytics-server/user-publisher-oas/introduction-pixel-perfect-publishing.html)
- 💻 **Töölaua Tööriistade Allalaadimise Juhend (Template Builder for Word/Excel):** [Download Desktop Tools for Publisher](https://docs.oracle.com/en/middleware/bi/analytics-server/user-publisher-oas/download-desktop-tools.html)

