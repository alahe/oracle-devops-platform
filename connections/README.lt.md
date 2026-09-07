<!-- [ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md) -->

# 🔌 Duomenų Bazių Ryšių ir VS Code Sąrankos Vadovas

Šis vadovas aprašo automatizuotą ir rankinį duomenų bazių ryšių registravimą **Oracle SQL Developer for VS Code** plėtiniui (vietiniame kompiuteryje ir Web IDE konteineryje) bei jungimąsi be slaptažodžių per Oracle Wallet (SEPS).

---

## 🔄 Dviejų Lygių Automatinis Registravimas (Host PC & Web IDE)

Visa platforma naudoja centralizuotą ryšių registravimo variklį (`scripts/register-connections.sh`), kuris vienu metu sukuria ir sinchronizuoja ryšius jūsų **vietinėje VS Code (Host PC)** ir **Web IDE konteineryje (`web-ide-dev`)**:

### 📊 Ryšių Registravimo Proceso Schema

```mermaid
flowchart TD
  START(["🚀 Pradžia:<br/>./scripts/setup-all.sh<br/>arba register-connections.sh"]) --> DISCOVER["🔍 1. Aptikti aktyvias DB<br/>ir įkelti YAML profilius"]
  
  DISCOVER --> WALLET["🔐 2. Nuskaityti slaptažodžius<br/>tiesiai iš SEPS Wallet<br/>(Zero-Trust atmintyje)"]
  
  WALLET --> BUILD_CONNS["📦 3. Sukurti ryšius<br/>(Host TCP & Konteinerio tinklas)"]
  
  BUILD_CONNS --> HOST_REG["💻 4. Registruoti vietiniame PC<br/>- SQLcl connect -save<br/>- ~/.dbtools & ~/.sqldev<br/>- Spalvų kodai iš profilio"]
  
  HOST_REG --> CHECK_WEBIDE{"❓ Ar Web IDE<br/>(web-ide-dev)<br/>konteineris veikia?"}
  
  CHECK_WEBIDE -->|"✅ TAIP / Veikia"| WEBIDE_REG["🌐 5. Registruoti Web IDE<br/>- Konteinerio SQLcl batch<br/>- /config/.dbtools/conns<br/>- /config/.sqldev/conns.json<br/>- Prieigos teisės chown abc"]
  
  CHECK_WEBIDE -->|"❌ NE / Nėra"| SANITIZE["🧹 6. Valyti folders.json<br/>(Pašalinti senus GUID<br/>Išvengti DBTU-03001)"]
  
  WEBIDE_REG --> SANITIZE
  
  SANITIZE --> READY(["🎉 Paruošta:<br/>1-Paspaudimo ryšiai<br/>PC ir Web IDE!"])
```

### Paleidimas per CLI:

```bash
./scripts/register-connections.sh
```
