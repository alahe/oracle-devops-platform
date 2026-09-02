[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏗️ Keskkondade Arhitektuursed Kavandid (15 Kureeritud Mudelit)

Käesolev kataloog on **keskkonna 15 kureeritud ja kanoonilise arhitektuurse kavandi (Blueprints)** keskne tõeallikas, mis on jaotatud **4 loogilisse dekaadipõhisesse gruppi**.

Iga blueprint (`.env.<N>-*`) defineerib tervikliku taristumudeli alates eraldiseisvast baasist või lüüsist kuni täieliku ettevõtte hübriidvirnani koos Web IDE-ga.

---

## 🚀 Blueprintide Haldamise & Juurutamise Käsud

Kasuta spetsiaalset juhtskripti **`./scripts/deploy-blueprint.sh`** (või `./scripts/setup-all.sh -b <N>`):

```bash
# 1. Kontrolli aktiivset blueprinti ja teenuste tervist:
./scripts/deploy-blueprint.sh --status

# 2. Juuruta või lülitu Blueprint 21 peale (VAIKIMISI 2-kihiline tootmislahendus koos Web IDE-ga):
./scripts/deploy-blueprint.sh -b 21

# 3. Juuruta Blueprint 31 (Täielik Ettevõtte Hübriidvirn: Forms + Publisher + APEX + Web IDE):
./scripts/deploy-blueprint.sh -b 31

# 4. Dry-run simulatsioon (eelvaade ilma konteinereid muutmata):
./scripts/deploy-blueprint.sh -b 21 --dry-run

# 5. Kuva 15 blueprinti tabel vormindatud kujul:
./scripts/setup-all.sh -lb

# 6. Käivita automatiseeritud puhta algseisuga test:
./scripts/setup-all.sh -tb 21
```

---

## 📊 Kanooniline 15 Blueprinti Arhitektuurimaatriks

```mermaid
graph TD
  subgraph Grupp 1: Üksiktooted Eraldi (1–9)
    BP1["BP 1: Eraldiseisev ALISE DB<br/>db-alise + app-ords (Port 1533)"]
    BP2["BP 2: Iseseisev ORDS Lüüs & Dev Hub<br/>app-ords (Pordid 8088/8448)"]
    BP3["BP 3: Eraldiseisev Proxy DB & APEX SSO<br/>db-proxy + app-ords (Port 1532)"]
    BP4["BP 4: Iseseisev Web-IDE Arendustöökoht<br/>web-ide-dev (Port 8090)"]
    BP5["BP 5: Eraldiseisev Analytics Publisher<br/>db-publisher + app-publisher (Pordid 1531, 9502)"]
    BP6["BP 6: Eraldiseisev Oracle Forms 14c<br/>db-forms + app-forms (Pordid 1534, 9001, 6082)"]
  end

  subgraph Grupp 2: Konsolideeritud Teenused (10–19)
    BP10["BP 10: Forms + Publisher Ühine DB<br/>db-publisher + app-forms + app-publisher"]
    BP11["BP 11: Konsolideeritud ORDS & Web-IDE<br/>app-ords + web-ide-dev"]
  end

  subgraph Grupp 3: Kihiline Ettevõtte Virn (20–29)
    BP20["BP 20: 1-DB Tuumikrakenduse Virn<br/>db-alise + app-ords + web-ide-dev"]
    BP21["🌟 BP 21 (PLATVORM VAIKIMISI): Kanooniline 2-Kihiline Virn<br/>db-proxy + db-alise + app-ords + web-ide-dev"]
    BP22["BP 22: 1-DB Kompaktne Aruandlusvirn<br/>db-alise + app-publisher + app-ords + web-ide-dev"]
    BP23["BP 23: Täielik Isoleeritud Aruandlusvirn (3 DB-d)<br/>db-publisher + db-proxy + db-alise + Publisher + ORDS + Web-IDE"]
    BP24["BP 24: Täielik Isoleeritud Forms Virn (3 DB-d)<br/>db-forms + db-proxy + db-alise + Forms + ORDS + Web-IDE"]
  end

  subgraph Grupp 4: Hübriidsed Virnad (30–39)
    BP30["BP 30: Kompaktne Ettevõtte Hübriidvirn<br/>db-publisher + db-alise + Forms + Pub + ORDS + Web-IDE"]
    BP31["🌟 BP 31: Ultimate Ettevõtte Hübriidvirn<br/>db-publisher + db-proxy + db-alise + Forms + Pub + ORDS + Web-IDE"]
  end
```

---

### 🔹 Grupp 1: Üksiktooted Eraldi (1–9)
| Nr | Faili Nimi | Käivitatavad Konteinerid | Pordid (Host) | Otstarve ja Arhitektuurne Kirjeldus |
| :--- | :--- | :--- | :--- | :--- |
| **1** | `.env.1-standalone-alise-db` | `db-alise`, `app-ords` | `1533`, `8088`, `8448` | **Eraldiseisev ALISE Äriandmebaas:** Spetsiaalne kohandatud rakenduste andmebaas äriskeemidele, PL/SQL koodile, DDL/DML lausetele ja sisemisele APEX & ORDS toele. |
| **2** | `.env.2-standalone-ords-devhub` | `app-ords` | `8088`, `8448` | **Iseseisev ORDS Lüüs & Dev Hub:** Eraldiseisev ORDS HTTP/HTTPS veebilüüs ja Developer Hub kaug- ning pilveandmebaasidele. |
| **3** | `.env.3-standalone-proxy-db` | `db-proxy`, `app-ords` | `1532`, `8088`, `8448` | **Eraldiseisev Proxy DB & APEX SSO:** APEX Proxy andmebaas turvaväravana ja välisühenduste vahendajana (REST API, Azure Entra ID, Kafka). |
| **4** | `.env.4-standalone-web-ide` | `web-ide-dev` | `8090` | **Iseseisev Web-IDE Arendustöökoht:** Brauseripõhine VS Code Web IDE koos Oracle SQL Developer laienduse, Antigravity ja lokaalse CI testimisega (`act`). |
| **5** | `.env.5-standalone-analytics-publisher` | `db-publisher`, `app-publisher` | `1531`, `9502` | **Eraldiseisev Analytics Publisher:** Oracle Analytics Publisher (Pixel-Perfect) koos spetsiaalse RCU taristu andmebaasiga (`db-publisher`). |
| **6** | `.env.6-standalone-oracle-forms` | `db-forms`, `app-forms` | `1534`, `9001`, `7001`, `6082` | **Eraldiseisev Oracle Forms 14c:** Oracle Forms 14c teenused ja HTML5 noVNC Forms Builder GUI koos eraldi Forms RCU andmebaasiga (`db-forms`). |

---

### 🔹 Grupp 2: Konsolideeritud Teenused (10–19)
| Nr | Faili Nimi | Käivitatavad Konteinerid | Pordid (Host) | Otstarve ja Arhitektuurne Kirjeldus |
| :--- | :--- | :--- | :--- | :--- |
| **10** | `.env.10-consolidated-forms-publisher-unified-db` | `db-publisher`, `app-forms`, `app-publisher` | `1531`, `9502`, `9001`, `6082` | **Forms + Publisher Ühine DB:** Forms 14c ja Analytics Publisher ühendatud ühe ühise 23ai andmebaasiga (`db-publisher`) mõlema RCU jaoks, säästes ~2.5 GB RAM-i. |
| **11** | `.env.11-consolidated-ords-web-ide` | `app-ords`, `web-ide-dev` | `8088`, `8448`, `8090` | **Konsolideeritud ORDS Lüüs & Web-IDE:** Integreeritud veebi- ja arendustöökohtade kiht (ORDS lüüs + code-server Web IDE) ühtses võrgus. |

---

### 🔹 Grupp 3: Kihiline Ettevõtte Virn (20–29)
| Nr | Faili Nimi | Käivitatavad Konteinerid | Pordid (Host) | Otstarve ja Arhitektuurne Kirjeldus |
| :--- | :--- | :--- | :--- | :--- |
| **20** | `.env.20-stack-alise-ords-webide` | `db-alise`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8448`, `8090` | **1-DB Tuumikrakenduse Virn:** Ühe andmebaasiga APEX tuumikvirn: ALISE äriandmebaas, ORDS veebilüüs ja brauseri Web IDE. |
| **21** | `.env.21-stack-alise-ords-proxy-webide` | `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev` | `1532`, `1533`, `8088`, `8448`, `8090` | **🌟 PLATVORM VAIKIMISI:** Standardne 2-kihiline turvaline võrgutopoloogia (eraldatud Proxy DB ja ALISE DB) koos APEX SSO, ORDS-i ja Web IDE-ga. |
| **22** | `.env.22-stack-alise-publisher-ords-webide` | `db-alise`, `app-publisher`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8448`, `9502`, `8090` | **1-DB Kompaktne Aruandlusvirn:** Ressursisäästlik aruandlusvirn, kus Analytics Publisher jagab RCU skeeme ALISE andmebaasis koos ORDS-i ja Web IDE-ga. |
| **23** | `.env.23-stack-alise-ords-proxy-webide-publisher` | `db-publisher`, `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev`, `app-publisher` | `1531-1533`, `8088`, `9502`, `8090` | **Täielik Isoleeritud 2-Kihiline Aruandlusvirn:** 3 eraldi andmebaasi (`db-publisher`, `db-proxy`, `db-alise`), WebLogic Publisher, ORDS ja Web IDE *(nõuab $\ge 12\text{ GB}$ RAM)*. |
| **24** | `.env.24-stack-alise-ords-proxy-webide-forms` | `db-forms`, `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev`, `app-forms` | `1532-1534`, `8088`, `9001`, `6082`, `8090` | **Täielik Isoleeritud 2-Kihiline Forms Virn:** 3 eraldi andmebaasi (`db-forms`, `db-proxy`, `db-alise`), Forms 14c teenused, noVNC, ORDS ja Web IDE *(nõuab $\ge 12\text{ GB}$ RAM)*. |

---

### 🔹 Grupp 4: Hübriidsed Virnad (30–39)
| Nr | Faili Nimi | Käivitatavad Konteinerid | Pordid (Host) | Otstarve ja Arhitektuurne Kirjeldus |
| :--- | :--- | :--- | :--- | :--- |
| **30** | `.env.30-hybrid-alise-forms-pub-ords-webide` | `db-publisher`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531`, `1533`, `8088`, `9502`, `9001`, `6082`, `8090` | **Kompaktne Ettevõtte Hübriidvirn:** Ressursisäästlik hübriidvirn: ALISE äribaas, konsolideeritud Forms & Publisher RCU baas (`db-publisher`) ning integreeritud ORDS & Web-IDE. |
| **31** | `.env.31-hybrid-alise-proxy-forms-pub-ords-webide` | `db-publisher`, `db-proxy`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531-1533`, `8088`, `9502`, `9001`, `6082`, `8090` | **🌟 ULTIMATE ETTEVÕTTE HÜBRIIDVIRN:** Täielik 2-kihiline Proxy + ALISE arhitektuur konsolideeritud Forms & Publisher RCU andmebaasi ja integreeritud ORDS & Web-IDE-ga *(nõuab $\ge 12\text{ GB}$ RAM)*. |

---

## 🔒 Turvalisus ja Käsitsi Kopeerimine

Kui soovid blueprinti käsitsi aktiveerida ilma skriptita:
```bash
cp config/blueprints/.env.3-db-alise-apex-ords-with-proxy .env
```
Kõik kohalikud muudatused tehakse faili `.env`, mis on `.gitignore` failis ning jääb ainult lokaalseks.