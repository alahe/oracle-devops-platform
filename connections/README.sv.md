<!-- [ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md) -->

# 🔌 Databasanslutningar och VS Code Konfigurationsguide

Denna guide beskriver automatisk och manuell registrering av databasanslutningar för **Oracle SQL Developer for VS Code** (på både lokal värddator och i containeriserad Web IDE) samt lösenordsfri anslutning via Oracle Wallet (SEPS).

---

## 🔄 Automatisk Registrering på Två Nivåer (Host PC & Web IDE)

Hela plattformen använder den centraliserade anslutningsmotorn (`scripts/register-connections.sh`), som skapar och synkroniserar databasanslutningar samtidigt i din **lokala VS Code (Host PC)** och **containeriserade Web IDE (`web-ide-dev`)**:

### 📊 Processdiagram för Anslutningsregistrering

```mermaid
flowchart TD
  START(["🚀 Start:<br/>./scripts/setup-all.sh<br/>eller register-connections.sh"]) --> DISCOVER["🔍 1. Identifiera aktiva databaser<br/>och ladda YAML-profiler"]
  
  DISCOVER --> WALLET["🔐 2. Hämta lösenord<br/>direkt från SEPS Wallet<br/>(Zero-Trust i minnet)"]
  
  WALLET --> BUILD_CONNS["📦 3. Bygg anslutningar<br/>(Värd-TCP & Containernätverk)"]
  
  BUILD_CONNS --> HOST_REG["💻 4. Registrera på värddatorn<br/>- SQLcl connect -save<br/>- ~/.dbtools & ~/.sqldev<br/>- Färgkodning från profil"]
  
  HOST_REG --> CHECK_WEBIDE{"❓ Körs Web IDE<br/>(web-ide-dev)<br/>containern?"}
  
  CHECK_WEBIDE -->|"✅ JA / Körs"| WEBIDE_REG["🌐 5. Registrera i Web IDE<br/>- Containerns SQLcl batch<br/>- /config/.dbtools/conns<br/>- /config/.sqldev/conns.json<br/>- Filrättigheter chown abc"]
  
  CHECK_WEBIDE -->|"❌ NEJ / Saknas"| SANITIZE["🧹 6. Rensa folders.json<br/>(Ta bort föräldralösa GUID<br/>Förhindra DBTU-03001)"]
  
  WEBIDE_REG --> SANITIZE
  
  SANITIZE --> READY(["🎉 Klart:<br/>1-Klicks anslutningar<br/>i värd och Web IDE!"])
```

### Körning via CLI:

```bash
./scripts/register-connections.sh
```

- **Host PC:** Registrerar anslutningar i `~/.dbtools/connections/` och `~/.sqldev/connections.json` (portar `localhost:1532`, `localhost:1533` etc.).
- **Web IDE:** När `web-ide-dev` är aktiv skapas anslutningar internt i containern (`db-proxy:1521`, `db-alise:1521` etc.).
- **Ordningsoberoende:** Web IDE kan starta före eller efter databaserna.
