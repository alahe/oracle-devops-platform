[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏗️ Arhitektūras Plāni (15 Kurēti Modeļi)

Šis katalogs kalpo kā **centrālais un kanoniskais patiesības avots 15 kurētiem arhitektūras plāniem**, kas sadalīti **4 loģiskās desmitgažu grupās**.

Katrs plāns (`.env.<N>-*`) definē pilnīgu infrastruktūras modeli no savrupas datubāzes vai vārtejas līdz pilnam uzņēmuma hibrīda stekam ar Web IDE.

---

## 🚀 Pārvaldības un Izvietošanas Komandas

Izmantojiet vadības skriptu **`./scripts/deploy-blueprint.sh`** (vai `./scripts/setup-all.sh -b <N>`):

```bash
# 1. Pārbaudīt aktīvo plānu un konteineru statusu:
./scripts/deploy-blueprint.sh --status --lang lv

# 2. Izvietot vai pārslēgties uz Blueprint 21 (NOKLUSĒJUMA 2-slāņu ražošanas steks ar Web IDE):
./scripts/deploy-blueprint.sh -b 21 --lang lv

# 3. Izvietot Blueprint 31 (Ultimate Enterprise hibrīda steks: Forms + Publisher + APEX + Web IDE):
./scripts/deploy-blueprint.sh -b 31 --lang lv

# 4. Dry-run simulācija (priekšskatījums bez konteineru izmaiņām):
./scripts/deploy-blueprint.sh -b 21 --dry-run

# 5. Parādīt visu 15 plānu tabulu:
./scripts/setup-all.sh -lb --lang lv

# 6. Palaist automatizētu tīru testu:
./scripts/setup-all.sh -tb 21
```

---

## 📊 Kanoniskā 15 Plānu Arhitektūras Matrica

```mermaid
graph TD
  subgraph 1. Grupa: Savrupi Produkti (1–9)
    BP1["BP 1: Savrupa ALISE DB<br/>db-alise + app-ords (Ports 1533)"]
    BP2["BP 2: Savrupa ORDS & Dev Hub<br/>app-ords (Porti 8088/8448)"]
    BP3["BP 3: Savrupa Proxy DB & APEX SSO<br/>db-proxy + app-ords (Ports 1532)"]
    BP4["BP 4: Savrupa Web-IDE Darba Stacija<br/>web-ide-dev (Ports 8090)"]
    BP5["BP 5: Savrupa Analytics Publisher<br/>db-publisher + app-publisher (Porti 1531, 9502)"]
    BP6["BP 6: Savrupa Oracle Forms 14c<br/>db-forms + app-forms (Porti 1534, 9001, 6082)"]
  end

  subgraph 2. Grupa: Konsolidētie Pakalpojumi (10–19)
    BP10["BP 10: Forms + Publisher Kopīga DB<br/>db-publisher + app-forms + app-publisher"]
    BP11["BP 11: Konsolidēts ORDS & Web-IDE<br/>app-ords + web-ide-dev"]
  end

  subgraph 3. Grupa: Slāņotais Uzņēmuma Steks (20–29)
    BP20["BP 20: 1-DB Kodola Lietotnes Steks<br/>db-alise + app-ords + web-ide-dev"]
    BP21["🌟 BP 21 (NOKLUSĒJUMS): Kanoniskais 2-Slāņu Steks<br/>db-proxy + db-alise + app-ords + web-ide-dev"]
    BP22["BP 22: 1-DB Kompakts Atskaišu Steks<br/>db-alise + app-publisher + app-ords + web-ide-dev"]
    BP23["BP 23: Pilnībā Izolēts Atskaišu Steks (3 DBs)<br/>db-publisher + db-proxy + db-alise + Publisher + ORDS + Web-IDE"]
    BP24["BP 24: Pilnībā Izolēts Forms Steks (3 DBs)<br/>db-forms + db-proxy + db-alise + Forms + ORDS + Web-IDE"]
  end

  subgraph 4. Grupa: Hibrīdie Steki (30–39)
    BP30["BP 30: Kompakts Uzņēmuma Hibrīda Steks<br/>db-publisher + db-alise + Forms + Pub + ORDS + Web-IDE"]
    BP31["🌟 BP 31: Ultimate Uzņēmuma Hibrīda Steks<br/>db-publisher + db-proxy + db-alise + Forms + Pub + ORDS + Web-IDE"]
  end
```

---

### 🔹 1. Grupa: Savrupi Produkti (1–9)
| Nr | Failu Nosaukums | Aktīvie Konteineri | Resursdatora Porti | Mērķis un Apraksts |
| :--- | :--- | :--- | :--- | :--- |
| **1** | `.env.1-standalone-alise-db` | `db-alise`, `app-ords` | `1533`, `8088`, `8448` | **Savrupa ALISE Biznesa Datubāze:** Dedicēta lietotņu datubāze biznesa shēmām, PL/SQL kodam un iekšējam APEX/ORDS. |
| **2** | `.env.2-standalone-ords-devhub` | `app-ords` | `8088`, `8448` | **Savrupa ORDS & Dev Hub:** HTTP/HTTPS vārteja un Developer Hub attālām un mākoņa datubāzēm. |
| **3** | `.env.3-standalone-proxy-db` | `db-proxy`, `app-ords` | `1532`, `8088`, `8448` | **Savrupa Proxy DB & APEX SSO:** Drošības vārteja un ārējo savienojumu starpnieks (REST API, Azure Entra ID, Kafka). |
| **4** | `.env.4-standalone-web-ide` | `web-ide-dev` | `8090` | **Savrupa Web-IDE Darba Stacija:** Pārlūkprogrammas VS Code Web IDE ar Oracle SQL Developer un lokālo CI testēšanu (`act`). |
| **5** | `.env.5-standalone-analytics-publisher` | `db-publisher`, `app-publisher` | `1531`, `9502` | **Savrupa Analytics Publisher:** Pixel-Perfect uzņēmuma atskaites ar dedicētu RCU datubāzi (`db-publisher`). |
| **6** | `.env.6-standalone-oracle-forms` | `db-forms`, `app-forms` | `1534`, `9001`, `7001`, `6082` | **Savrupa Oracle Forms 14c:** Forms 14c pakalpojumi un HTML5 noVNC Forms Builder GUI ar Forms RCU datubāzi (`db-forms`). |

---

### 🔹 2. Grupa: Konsolidētie Pakalpojumi (10–19)
| Nr | Failu Nosaukums | Aktīvie Konteineri | Resursdatora Porti | Mērķis un Apraksts |
| :--- | :--- | :--- | :--- | :--- |
| **10** | `.env.10-consolidated-forms-publisher-unified-db` | `db-publisher`, `app-forms`, `app-publisher` | `1531`, `9502`, `9001`, `6082` | **Forms + Publisher Kopīga DB:** Forms 14c un Analytics Publisher apvienoti vienā 23ai DB (`db-publisher`) abām RCU shēmām (~2.5 GB RAM ietaupījums). |
| **11** | `.env.11-consolidated-ords-web-ide` | `app-ords`, `web-ide-dev` | `8088`, `8448`, `8090` | **Konsolidēta ORDS Vārteja & Web-IDE:** Integrēts tīmekļa un izstrādātāja slānis vienotā tīklā. |

---

### 🔹 3. Grupa: Slāņotais Uzņēmuma Steks (20–29)
| Nr | Failu Nosaukums | Aktīvie Konteineri | Resursdatora Porti | Mērķis un Apraksts |
| :--- | :--- | :--- | :--- | :--- |
| **20** | `.env.20-stack-alise-ords-webide` | `db-alise`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8448`, `8090` | **1-DB Kodola Lietotnes Steks:** Viena datubāzes APEX kodola steks: ALISE biznesa datubāze, ORDS vārteja un Web IDE. |
| **21** | `.env.21-stack-alise-ords-proxy-webide` | `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev` | `1532`, `1533`, `8088`, `8448`, `8090` | **🌟 NOKLUSĒJUMS:** Kanoniskā 2-slāņu drošā tīkla topoloģija (Proxy DB un ALISE DB) ar APEX SSO, ORDS un Web IDE. |
| **22** | `.env.22-stack-alise-publisher-ords-webide` | `db-alise`, `app-publisher`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8448`, `9502`, `8090` | **1-DB Kompakts Atskaišu Steks:** Resursu efektīvs atskaišu steks, kur Analytics Publisher koplieto RCU shēmas ALISE datubāzē. |
| **23** | `.env.23-stack-alise-ords-proxy-webide-publisher` | `db-publisher`, `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev`, `app-publisher` | `1531-1533`, `8088`, `9502`, `8090` | **Pilnībā Izolēts 2-Slāņu Atskaišu Steks:** 3 izolētas datubāzes (`db-publisher`, `db-proxy`, `db-alise`), WebLogic Publisher, ORDS un Web IDE *(nepieciešama $\ge 12\text{ GB}$ RAM)*. |
| **24** | `.env.24-stack-alise-ords-proxy-webide-forms` | `db-forms`, `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev`, `app-forms` | `1532-1534`, `8088`, `9001`, `6082`, `8090` | **Pilnībā Izolēts 2-Slāņu Forms Steks:** 3 izolētas datubāzes (`db-forms`, `db-proxy`, `db-alise`), Forms 14c, noVNC, ORDS un Web IDE *(nepieciešama $\ge 12\text{ GB}$ RAM)*. |

---

### 🔹 4. Grupa: Hibrīdie Steki (30–39)
| Nr | Failu Nosaukums | Aktīvie Konteineri | Resursdatora Porti | Mērķis un Apraksts |
| :--- | :--- | :--- | :--- | :--- |
| **30** | `.env.30-hybrid-alise-forms-pub-ords-webide` | `db-publisher`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531`, `1533`, `8088`, `9502`, `9001`, `6082`, `8090` | **Kompakts Uzņēmuma Hibrīda Steks:** Resursu efektīvs hibrīda steks: ALISE DB, konsolidēta Forms & Publisher RCU DB (`db-publisher`) un integrēts ORDS & Web-IDE. |
| **31** | `.env.31-hybrid-alise-proxy-forms-pub-ords-webide` | `db-publisher`, `db-proxy`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531-1533`, `8088`, `9502`, `9001`, `6082`, `8090` | **🌟 ULTIMATE UZŅĒMUMA HIBRĪDA STEKS:** Pilna 2-slāņu Proxy + ALISE arhitektūra ar konsolidētu Forms & Publisher RCU datubāzi un integrētu ORDS & Web-IDE *(nepieciešama $\ge 12\text{ GB}$ RAM)*. |
