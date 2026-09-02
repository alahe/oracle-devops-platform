[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏗️ Ympäristön Arkkitehtuurisuunnitelmat (15 Kuratoitua Mallia)

Tämä luettelo on **ympäristön 15 kuratoidun ja kanonisen arkkitehtuurisuunnitelman (Blueprints)** keskitetty tietolähde, jaettuna **4 loogiseen vuosikymmenpohjaiseen ryhmään**.

Jokainen blueprint (`.env.<N>-*`) määrittää kokonaisvaltaisen infrastruktuurimallin erillisestä tietokannasta tai yhdyskäytävästä täydelliseen yrityshybridipinoon Web IDE:llä.

---

## 🚀 Blueprintien Hallinta- ja Käyttöönottokomennot

Käytä orkestrointityökalua **`./scripts/deploy-blueprint.sh`** (tai `./scripts/setup-all.sh -b <N>`):

```bash
# 1. Tarkista aktiivinen blueprint ja palveluiden tila:
./scripts/deploy-blueprint.sh --status --lang fi

# 2. Ota käyttöön Blueprint 21 (OLETUS 2-kerroksinen tuotantoratkaisu Web IDE:llä):
./scripts/deploy-blueprint.sh -b 21 --lang fi

# 3. Ota käyttöön Blueprint 31 (Täysi Yrityshybridipino: Forms + Publisher + APEX + Web IDE):
./scripts/deploy-blueprint.sh -b 31 --lang fi

# 4. Dry-run simulointi (esikatselu ilman konttimuutoksia):
./scripts/deploy-blueprint.sh -b 21 --dry-run

# 5. Näytä 15 blueprintin taulukko:
./scripts/setup-all.sh -lb --lang fi

# 6. Suorita automatisoitu puhdas testaus:
./scripts/setup-all.sh -tb 21
```

---

## 📊 Kanoninen 15 Blueprintin Arkkitehtuurimatriisi

```mermaid
graph TD
  subgraph Ryhmä 1: Erilliset Yksittäistuotteet (1–9)
    BP1["BP 1: Erillinen ALISE DB<br/>db-alise + app-ords (Portti 1533)"]
    BP2["BP 2: Erillinen ORDS & Dev Hub<br/>app-ords (Portit 8088/8448)"]
    BP3["BP 3: Erillinen Proxy DB & APEX SSO<br/>db-proxy + app-ords (Portti 1532)"]
    BP4["BP 4: Erillinen Web-IDE Työasema<br/>web-ide-dev (Portti 8090)"]
    BP5["BP 5: Erillinen Analytics Publisher<br/>db-publisher + app-publisher (Portit 1531, 9502)"]
    BP6["BP 6: Erillinen Oracle Forms 14c<br/>db-forms + app-forms (Portit 1534, 9001, 6082)"]
  end

  subgraph Ryhmä 2: Yhdistetyt Palvelut (10–19)
    BP10["BP 10: Forms + Publisher Yhteinen DB<br/>db-publisher + app-forms + app-publisher"]
    BP11["BP 11: Yhdistetty ORDS & Web-IDE<br/>app-ords + web-ide-dev"]
  end

  subgraph Ryhmä 3: Kerroksellinen Yrityspino (20–29)
    BP20["BP 20: 1-DB Ydinsovelluspino<br/>db-alise + app-ords + web-ide-dev"]
    BP21["🌟 BP 21 (ALUSTAN OLETUS): Kanoninen 2-Kerroksinen Pino<br/>db-proxy + db-alise + app-ords + web-ide-dev"]
    BP22["BP 22: 1-DB Kompakti Raportointipino<br/>db-alise + app-publisher + app-ords + web-ide-dev"]
    BP23["BP 23: Täysi Eristetty Raportointipino (3 DB:tä)<br/>db-publisher + db-proxy + db-alise + Publisher + ORDS + Web-IDE"]
    BP24["BP 24: Täysi Eristetty Forms-Pino (3 DB:tä)<br/>db-forms + db-proxy + db-alise + Forms + ORDS + Web-IDE"]
  end

  subgraph Ryhmä 4: Hybridipinot (30–39)
    BP30["BP 30: Kompakti Yrityshybridipino<br/>db-publisher + db-alise + Forms + Pub + ORDS + Web-IDE"]
    BP31["🌟 BP 31: Ultimate Yrityshybridipino<br/>db-publisher + db-proxy + db-alise + Forms + Pub + ORDS + Web-IDE"]
  end
```

---

### 🔹 Ryhmä 1: Erilliset Yksittäistuotteet (1–9)
| Nro | Tiedostonimi | Kontit | Isännän Portit | Tarkoitus ja Arkkitehtuuri |
| :--- | :--- | :--- | :--- | :--- |
| **1** | `.env.1-standalone-alise-db` | `db-alise`, `app-ords` | `1533`, `8088`, `8448` | **Erillinen ALISE-Liiketoimintatietokanta:** Erillinen sovellustietokanta liiketoimintaskeemoille, PL/SQL-koodille ja sisäiselle APEX/ORDS:lle. |
| **2** | `.env.2-standalone-ords-devhub` | `app-ords` | `8088`, `8448` | **Erillinen ORDS & Dev Hub:** Erillinen ORDS HTTP/HTTPS -yhdyskäytävä ja Dev Hub etä- ja pilvitietokannoille. |
| **3** | `.env.3-standalone-proxy-db` | `db-proxy`, `app-ords` | `1532`, `8088`, `8448` | **Erillinen Proxy DB & APEX SSO:** APEX Proxy -tietokanta tietoturvayhdyskäytävänä (REST API, Azure Entra ID, Kafka). |
| **4** | `.env.4-standalone-web-ide` | `web-ide-dev` | `8090` | **Erillinen Web-IDE Työasema:** Selainpohjainen VS Code Web IDE SQL Developerilla, Antigravitylla ja paikallisella CI-testauksella (`act`). |
| **5** | `.env.5-standalone-analytics-publisher` | `db-publisher`, `app-publisher` | `1531`, `9502` | **Erillinen Analytics Publisher:** Oracle Analytics Publisher (Pixel-Perfect) erillisellä RCU-infrastruktuuritietokannalla (`db-publisher`). |
| **6** | `.env.6-standalone-oracle-forms` | `db-forms`, `app-forms` | `1534`, `9001`, `7001`, `6082` | **Erillinen Oracle Forms 14c:** Forms 14c -palvelut ja HTML5 noVNC Forms Builder GUI erillisellä Forms RCU -tietokannalla (`db-forms`). |

---

### 🔹 Ryhmä 2: Yhdistetyt Palvelut (10–19)
| Nro | Tiedostonimi | Kontit | Isännän Portit | Tarkoitus ja Arkkitehtuuri |
| :--- | :--- | :--- | :--- | :--- |
| **10** | `.env.10-consolidated-forms-publisher-unified-db` | `db-publisher`, `app-forms`, `app-publisher` | `1531`, `9502`, `9001`, `6082` | **Forms + Publisher Yhteinen DB:** Forms 14c ja Analytics Publisher yhdistettynä yhteen 23ai-tietokantaan (`db-publisher`) molemmille RCU-skeemoille (~2.5 GB RAM-säästö). |
| **11** | `.env.11-consolidated-ords-web-ide` | `app-ords`, `web-ide-dev` | `8088`, `8448`, `8090` | **Yhdistetty ORDS & Web-IDE:** Integroitu verkko- ja kehittäjäkerros (ORDS HTTP/HTTPS + code-server Web IDE) yhtenäisessä verkossa. |

---

### 🔹 Ryhmä 3: Kerroksellinen Yrityspino (20–29)
| Nro | Tiedostonimi | Kontit | Isännän Portit | Tarkoitus ja Arkkitehtuuri |
| :--- | :--- | :--- | :--- | :--- |
| **20** | `.env.20-stack-alise-ords-webide` | `db-alise`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8448`, `8090` | **1-DB Ydinsovelluspino:** Yhden tietokannan APEX-ydinpino: ALISE-liiketoimintatietokanta, ORDS-yhdyskäytävä ja selainpohjainen Web IDE. |
| **21** | `.env.21-stack-alise-ords-proxy-webide` | `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev` | `1532`, `1533`, `8088`, `8448`, `8090` | **🌟 ALUSTAN OLETUS:** Standardi 2-kerroksinen tietoturvallinen topologia (Proxy DB ja ALISE DB) APEX SSO:lla, ORDS:lla ja Web IDE:llä. |
| **22** | `.env.22-stack-alise-publisher-ords-webide` | `db-alise`, `app-publisher`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8448`, `9502`, `8090` | **1-DB Kompakti Raportointipino:** Resurssitehokas raportointipino, jossa Analytics Publisher jakaa RCU-skeemat ALISE-tietokannassa. |
| **23** | `.env.23-stack-alise-ords-proxy-webide-publisher` | `db-publisher`, `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev`, `app-publisher` | `1531-1533`, `8088`, `9502`, `8090` | **Täysi Eristetty 2-Kerroksinen Raportointipino:** 3 erillistä tietokantaa (`db-publisher`, `db-proxy`, `db-alise`), WebLogic Publisher, ORDS ja Web IDE *(vaatii $\ge 12\text{ GB}$ RAM)*. |
| **24** | `.env.24-stack-alise-ords-proxy-webide-forms` | `db-forms`, `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev`, `app-forms` | `1532-1534`, `8088`, `9001`, `6082`, `8090` | **Täysi Eristetty 2-Kerroksinen Forms-Pino:** 3 erillistä tietokantaa (`db-forms`, `db-proxy`, `db-alise`), Forms 14c, noVNC, ORDS ja Web IDE *(vaatii $\ge 12\text{ GB}$ RAM)*. |

---

### 🔹 Ryhmä 4: Hybridipinot (30–39)
| Nro | Tiedostonimi | Kontit | Isännän Portit | Tarkoitus ja Arkkitehtuuri |
| :--- | :--- | :--- | :--- | :--- |
| **30** | `.env.30-hybrid-alise-forms-pub-ords-webide` | `db-publisher`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531`, `1533`, `8088`, `9502`, `9001`, `6082`, `8090` | **Kompakti Yrityshybridipino:** Resurssitehokas hybridipino: ALISE-tietokanta, yhdistetty Forms & Publisher RCU DB (`db-publisher`) ja integroitu ORDS & Web-IDE. |
| **31** | `.env.31-hybrid-alise-proxy-forms-pub-ords-webide` | `db-publisher`, `db-proxy`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531-1533`, `8088`, `9502`, `9001`, `6082`, `8090` | **🌟 ULTIMATE YRITYSHYBRIDIPINO:** Täysi 2-kerroksinen Proxy + ALISE -arkkitehtuuri yhdistetyllä Forms & Publisher RCU -tietokannalla ja integroidulla ORDS & Web-IDE:llä *(vaatii $\ge 12\text{ GB}$ RAM)*. |
