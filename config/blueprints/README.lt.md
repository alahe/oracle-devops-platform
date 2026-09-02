[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏗️ Architektūros Planai (15 Kuruotų Modelių)

Šis katalogas yra **centrinis ir kanoninis tiesos šaltinis 15 kuruojamų architektūros planų**, suskirstytų į **4 logines dešimtmečių grupes**.

Kiekvienas planas (`.env.<N>-*`) apibrėžia visapusišką infrastruktūros modelį nuo autonominės duomenų bazės ar šliuzo iki pilno įmonės hibridinio paketo su Web IDE.

---

## 🚀 Valdymo ir Diegimo Komandos

Naudokite valdymo scenarijų **`./scripts/deploy-blueprint.sh`** (arba `./scripts/setup-all.sh -b <N>`):

```bash
# 1. Patikrinti aktyvų planą ir konteinerių būseną:
./scripts/deploy-blueprint.sh --status --lang lt

# 2. Įdiegti arba persijungti į Blueprint 21 (NUMATYTASIS 2 sluoksnių gamybos paketas su Web IDE):
./scripts/deploy-blueprint.sh -b 21 --lang lt

# 3. Įdiegti Blueprint 31 (Ultimate Enterprise hibridinis paketas: Forms + Publisher + APEX + Web IDE):
./scripts/deploy-blueprint.sh -b 31 --lang lt

# 4. Dry-run modeliavimas (peržiūra be konteinerių pakeitimų):
./scripts/deploy-blueprint.sh -b 21 --dry-run

# 5. Rodyti visų 15 planų lentelę:
./scripts/setup-all.sh -lb --lang lt

# 6. Paleisti automatizuotą švarų testą:
./scripts/setup-all.sh -tb 21
```

---

## 📊 Kanoninė 15 Planų Architektūros Matrica

```mermaid
graph TD
  subgraph 1 Grupė: Atskiri Produktai (1–9)
    BP1["BP 1: Atskira ALISE DB<br/>db-alise + app-ords (Prievadas 1533)"]
    BP2["BP 2: Atskiras ORDS & Dev Hub<br/>app-ords (Prievadai 8088/8448)"]
    BP3["BP 3: Atskira Proxy DB & APEX SSO<br/>db-proxy + app-ords (Prievadas 1532)"]
    BP4["BP 4: Atskira Web-IDE Darbo Vieta<br/>web-ide-dev (Prievadas 8090)"]
    BP5["BP 5: Atskira Analytics Publisher<br/>db-publisher + app-publisher (Prievadai 1531, 9502)"]
    BP6["BP 6: Atskira Oracle Forms 14c<br/>db-forms + app-forms (Prievadai 1534, 9001, 6082)"]
  end

  subgraph 2 Grupė: Konsoliduotos Paslaugos (10–19)
    BP10["BP 10: Forms + Publisher Bendra DB<br/>db-publisher + app-forms + app-publisher"]
    BP11["BP 11: Konsoliduotas ORDS & Web-IDE<br/>app-ords + web-ide-dev"]
  end

  subgraph 3 Grupė: Sluoksniuotas Įmonės Paketas (20–29)
    BP20["BP 20: 1-DB Pagrindinės Programos Paketas<br/>db-alise + app-ords + web-ide-dev"]
    BP21["🌟 BP 21 (NUMATYTASIS): Kanoninis 2 Sluoksnių Paketas<br/>db-proxy + db-alise + app-ords + web-ide-dev"]
    BP22["BP 22: 1-DB Kompaktiškas Ataskaitų Paketas<br/>db-alise + app-publisher + app-ords + web-ide-dev"]
    BP23["BP 23: Visiškai Izoliuotas Ataskaitų Paketas (3 DBs)<br/>db-publisher + db-proxy + db-alise + Publisher + ORDS + Web-IDE"]
    BP24["BP 24: Visiškai Izoliuotas Forms Paketas (3 DBs)<br/>db-forms + db-proxy + db-alise + Forms + ORDS + Web-IDE"]
  end

  subgraph 4 Grupė: Hibridiniai Paketai (30–39)
    BP30["BP 30: Kompaktiškas Įmonės Hibridinis Paketas<br/>db-publisher + db-alise + Forms + Pub + ORDS + Web-IDE"]
    BP31["🌟 BP 31: Ultimate Įmonės Hibridinis Paketas<br/>db-publisher + db-proxy + db-alise + Forms + Pub + ORDS + Web-IDE"]
  end
```

---

### 🔹 1 Grupė: Atskiri Produktai (1–9)
| Nr | Failo Pavadinimas | Aktyvūs Konteineriai | Pagrindinio Kompiuterio Prievadai | Paskirtis ir Aprašymas |
| :--- | :--- | :--- | :--- | :--- |
| **1** | `.env.1-standalone-alise-db` | `db-alise`, `app-ords` | `1533`, `8088`, `8448` | **Atskiras ALISE Verslo DB:** Dedikuota taikomosios programos duomenų bazė verslo schemoms, PL/SQL kodui ir vidiniam APEX/ORDS. |
| **2** | `.env.2-standalone-ords-devhub` | `app-ords` | `8088`, `8448` | **Atskiras ORDS & Dev Hub:** HTTP/HTTPS šliuzas ir Developer Hub nuotolinėms bei debesų duomenų bazėms. |
| **3** | `.env.3-standalone-proxy-db` | `db-proxy`, `app-ords` | `1532`, `8088`, `8448` | **Atskiras Proxy DB & APEX SSO:** Saugumo šliuzas ir išorinių ryšių tarpininkas (REST API, Azure Entra ID, Kafka). |
| **4** | `.env.4-standalone-web-ide` | `web-ide-dev` | `8090` | **Atskiras Web-IDE Darbo Vieta:** Naršyklės VS Code Web IDE su Oracle SQL Developer ir vietiniu CI testavimu (`act`). |
| **5** | `.env.5-standalone-analytics-publisher` | `db-publisher`, `app-publisher` | `1531`, `9502` | **Atskiras Analytics Publisher:** Pixel-Perfect įmonės ataskaitos su dedikuota RCU duomenų baze (`db-publisher`). |
| **6** | `.env.6-standalone-oracle-forms` | `db-forms`, `app-forms` | `1534`, `9001`, `7001`, `6082` | **Atskiras Oracle Forms 14c:** Forms 14c paslaugos ir HTML5 noVNC Forms Builder GUI su Forms RCU duomenų baze (`db-forms`). |

---

### 🔹 2 Grupė: Konsoliduotos Paslaugos (10–19)
| Nr | Failo Pavadinimas | Aktyvūs Konteineriai | Pagrindinio Kompiuterio Prievadai | Paskirtis ir Aprašymas |
| :--- | :--- | :--- | :--- | :--- |
| **10** | `.env.10-consolidated-forms-publisher-unified-db` | `db-publisher`, `app-forms`, `app-publisher` | `1531`, `9502`, `9001`, `6082` | **Forms + Publisher Bendra DB:** Forms 14c ir Analytics Publisher sujungti į vieną 23ai DB (`db-publisher`) abiem RCU schemoms (~2.5 GB RAM sutaupymas). |
| **11** | `.env.11-consolidated-ords-web-ide` | `app-ords`, `web-ide-dev` | `8088`, `8448`, `8090` | **Konsoliduotas ORDS Šliuzas & Web-IDE:** Integruotas žiniatinklio ir kūrėjo sluoksnis vieningame tinkle. |

---

### 🔹 3 Grupė: Sluoksniuotas Įmonės Paketas (20–29)
| Nr | Failo Pavadinimas | Aktyvūs Konteineriai | Pagrindinio Kompiuterio Prievadai | Paskirtis ir Aprašymas |
| :--- | :--- | :--- | :--- | :--- |
| **20** | `.env.20-stack-alise-ords-webide` | `db-alise`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8448`, `8090` | **1-DB Pagrindinės Programos Paketas:** Vienos duomenų bazės APEX pagrindinis paketas: ALISE verslo DB, ORDS šliuzas ir Web IDE. |
| **21** | `.env.21-stack-alise-ords-proxy-webide` | `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev` | `1532`, `1533`, `8088`, `8448`, `8090` | **🌟 NUMATYTASIS:** Kanoninė 2 sluoksnių saugaus tinklo topologija (Proxy DB ir ALISE DB) su APEX SSO, ORDS ir Web IDE. |
| **22** | `.env.22-stack-alise-publisher-ords-webide` | `db-alise`, `app-publisher`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8448`, `9502`, `8090` | **1-DB Kompaktiškas Ataskaitų Paketas:** Resursus taupantis ataskaitų paketas, kuriame Analytics Publisher dalijasi RCU schemomis ALISE duomenų bazėje. |
| **23** | `.env.23-stack-alise-ords-proxy-webide-publisher` | `db-publisher`, `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev`, `app-publisher` | `1531-1533`, `8088`, `9502`, `8090` | **Visiškai Izoliuotas 2 Sluoksnių Ataskaitų Paketas:** 3 izoliuotos duomenų bazės (`db-publisher`, `db-proxy`, `db-alise`), WebLogic Publisher, ORDS ir Web IDE *(reikalauja $\ge 12\text{ GB}$ RAM)*. |
| **24** | `.env.24-stack-alise-ords-proxy-webide-forms` | `db-forms`, `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev`, `app-forms` | `1532-1534`, `8088`, `9001`, `6082`, `8090` | **Visiškai Izoliuotas 2 Sluoksnių Forms Paketas:** 3 izoliuotos duomenų bazės (`db-forms`, `db-proxy`, `db-alise`), Forms 14c, noVNC, ORDS ir Web IDE *(reikalauja $\ge 12\text{ GB}$ RAM)*. |

---

### 🔹 4 Grupė: Hibridiniai Paketai (30–39)
| Nr | Failo Pavadinimas | Aktyvūs Konteineriai | Pagrindinio Kompiuterio Prievadai | Paskirtis ir Aprašymas |
| :--- | :--- | :--- | :--- | :--- |
| **30** | `.env.30-hybrid-alise-forms-pub-ords-webide` | `db-publisher`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531`, `1533`, `8088`, `9502`, `9001`, `6082`, `8090` | **Kompaktiškas Įmonės Hibridinis Paketas:** Resursus taupantis hibridinis paketas: ALISE DB, konsoliduota Forms & Publisher RCU DB (`db-publisher`) ir integruotas ORDS & Web-IDE. |
| **31** | `.env.31-hybrid-alise-proxy-forms-pub-ords-webide` | `db-publisher`, `db-proxy`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531-1533`, `8088`, `9502`, `9001`, `6082`, `8090` | **🌟 ULTIMATE ĮMONĖS HIBRIDINIS PAKETAS:** Pilna 2 sluoksnių Proxy + ALISE architektūra su konsoliduota Forms & Publisher RCU duomenų baze ir integruotu ORDS & Web-IDE *(reikalauja $\ge 12\text{ GB}$ RAM)*. |
