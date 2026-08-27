# ORDS (Oracle REST Data Services) Profiilid (`config/profiles/ords/`)

Selles kaustas asuvad **ORDS-i ilmutatud profiilid (Explicit ORDS Profiles)**, mis kirjeldavad ORDS-i käitusmudeleid ja pordi/konteineri seadistusi.

---

## 📁 Saadaval Profiilid

1. **`app-ords-standard.yaml`** (id: `app-ords-standard`)
   - Standardne Tsentraalne Multi-Pool ORDS server ametliku Oracle ORDS konteineripildiga (`container-registry.oracle.com/database/ords:latest`).
   - Pordid: HTTP `8088`, HTTPS `8448`.

2. **`app-ords-standalone.yaml`** (id: `app-ords-standalone`)
   - Eraldiseisev Standalone Podman ORDS teenus eraldi portidel `8085` / `8445`.

3. **`app-ords-external.yaml`** (id: `app-ords-external`)
   - Ettevõtte välise korporatiivse ORDS serveri profiil (kaug-andmebaasi suunamiseks).
