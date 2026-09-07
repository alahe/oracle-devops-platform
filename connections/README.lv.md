<!-- [ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md) -->

# 🔌 Datu Bāzu Savienojumu un VS Code Konfigurācijas Rokasgrāmata

Šī rokasgrāmata apraksta Oracle datubāzu savienojumu automātisku un manuālu reģistrāciju paplašinājumam **Oracle SQL Developer for VS Code** (gan lokālajā datorā, gan Web IDE konteinerā), kā arī bezparoļu savienojumus ar Oracle Wallet (SEPS).

---

## 🔄 Divlīmeņu Automātiskā Reģistrācija (Host PC & Web IDE)

Visa platforma izmanto centralizētu savienojumu reģistrācijas dzinēju (`scripts/register-connections.sh`), kas vienlaikus izveido un sinhronizē savienojumus jūsu **lokālajā VS Code (Host PC)** un **Web IDE konteinerā (`web-ide-dev`)**:

### 📊 Savienojumu Reģistrācijas Procesa Shēma

```mermaid
flowchart TD
  START(["🚀 Sākums:<br/>./scripts/setup-all.sh<br/>vai register-connections.sh"]) --> DISCOVER["🔍 1. Noteikt aktīvās DB<br/>un ielādēt YAML profilus"]
  
  DISCOVER --> WALLET["🔐 2. Nolasīt paroles<br/>tieši no SEPS Wallet<br/>(Zero-Trust atmiņā)"]
  
  WALLET --> BUILD_CONNS["📦 3. Izveidot savienojumus<br/>(Datora TCP & Konteinera tīkls)"]
  
  BUILD_CONNS --> HOST_REG["💻 4. Reģistrēt lokālajā datorā<br/>- SQLcl connect -save<br/>- ~/.dbtools & ~/.sqldev<br/>- Krāsu kodi no profila"]
  
  HOST_REG --> CHECK_WEBIDE{"❓ Vai Web IDE<br/>(web-ide-dev)<br/>konteiners darbojas?"}
  
  CHECK_WEBIDE -->|"✅ JĀ / Darbojas"| WEBIDE_REG["🌐 5. Reģistrēt Web IDE<br/>- Konteinera SQLcl batch<br/>- /config/.dbtools/conns<br/>- /config/.sqldev/conns.json<br/>- Piekļuves tiesības chown abc"]
  
  CHECK_WEBIDE -->|"❌ NĒ / Trūkst"| SANITIZE["🧹 6. Tīrīt folders.json<br/>(Noņemt neesošus GUID<br/>Novērst DBTU-03001)"]
  
  WEBIDE_REG --> SANITIZE
  
  SANITIZE --> READY(["🎉 Gatavs:<br/>1-Klikšķa savienojumi<br/>datorā un Web IDE!"])
```

### Palaišana no komandrindas:

```bash
./scripts/register-connections.sh
```
