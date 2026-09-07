<!-- [ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md) -->

# 🔌 Tietokantayhteyksien ja VS Coden Asennusopas

Tämä opas kuvaa Oracle-tietokantayhteyksien automaattista ja manuaalista rekisteröintiä **Oracle SQL Developer for VS Code** -laajennukselle (sekä paikallisella isäntäkoneella että konttipohjaisessa Web IDE:ssä) ja salasanatonta yhdistämistä Oracle Walletin (SEPS) avulla.

---

## 🔄 Kaksitasoinen Automaattinen Rekisteröinti (Host PC & Web IDE)

Koko alusta käyttää keskitettyä yhteyksien rekisteröintimoottoria (`scripts/register-connections.sh`), joka luo ja synkronoi tietokantayhteydet samanaikaisesti **paikalliseen VS Codeen (Host PC)** ja **konttipohjaiseen Web IDE:hen (`web-ide-dev`)**:

### 📊 Yhteyksien Rekisteröinnin Prosessikaavio

```mermaid
flowchart TD
  START(["🚀 Käynnistys:<br/>./scripts/setup-all.sh<br/>tai register-connections.sh"]) --> DISCOVER["🔍 1. Tunnista aktiiviset tietokannat<br/>ja lataa YAML-profiilit"]
  
  DISCOVER --> WALLET["🔐 2. Hae salasanat<br/>suoraan SEPS Walletista<br/>(Zero-Trust muistissa)"]
  
  WALLET --> BUILD_CONNS["📦 3. Muodosta yhteydet<br/>(Host TCP & Konttiverkko)"]
  
  BUILD_CONNS --> HOST_REG["💻 4. Rekisteröi isäntäkoneella<br/>- SQLcl connect -save<br/>- ~/.dbtools & ~/.sqldev<br/>- Värikoodit profiilista"]
  
  HOST_REG --> CHECK_WEBIDE{"❓ Onko Web IDE<br/>(web-ide-dev)<br/>kontti käynnissä?"}
  
  CHECK_WEBIDE -->|"✅ KYLLÄ / Käynnissä"| WEBIDE_REG["🌐 5. Rekisteröi Web IDE:ssä<br/>- Kontin SQLcl batch<br/>- /config/.dbtools/conns<br/>- /config/.sqldev/conns.json<br/>- Tiedosto-oikeudet chown abc"]
  
  CHECK_WEBIDE -->|"❌ EI / Ei käynnissä"| SANITIZE["🧹 6. Siivoa folders.json<br/>(Poista orvot GUID-tunnisteet<br/>Estä DBTU-03001)"]
  
  WEBIDE_REG --> SANITIZE
  
  SANITIZE --> READY(["🎉 Valmis:<br/>1-Klikkauksen yhteydet<br/>isännässä ja Web IDE:ssä!"])
```

### Komentorivikäyttö:

```bash
./scripts/register-connections.sh
```

- **Host PC:** Rekisteröi yhteydet hakemistoihin `~/.dbtools/connections/` ja `~/.sqldev/connections.json` (isäntäportit `localhost:1532`, `localhost:1533` jne.).
- **Web IDE:** Kun `web-ide-dev` on aktiivinen, luo yhteydet kontin sisällä (`db-proxy:1521`, `db-alise:1521` jne.) ja tallentaa salasanat kontin säilöön.
- **Järjestyksestä riippumaton:** Web IDE voi käynnistyä ennen tai jälkeen tietokantojen. Yhteydet synkronoidaan automaattisesti.

---

## 🔐 Salasanaton Yhdistäminen Oracle Walletin (SEPS) Avulla

Paikallisessa kehitysympäristössä todennus suojataan **Oracle Walletin (SEPS)** avulla ilman selkokielisiä salasanoja.

### Isäntäkoneen asetukset:
```bash
export TNS_ADMIN=$(pwd)/config/tns_admin
```

### 🔌 Yhdistäminen SQLcl:llä:
```bash
# Kehittäjänä
sql /@DB_PROXY_DEV

# SYSDBA-oikeuksilla
sql /@DB_PROXY_SYS as sysdba
```
