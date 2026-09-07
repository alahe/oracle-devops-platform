# ORDS (Oracle REST Data Services) Profiilid (`config/profiles/ords/`)

Selles kaustas asuvad **ORDS-i deklareeritud profiilid (Explicit ORDS Profiles)**, mis kirjeldavad ORDS-i käitusmudeleid ja võrguseadistusi vastavalt Rule 11 (Clean Blueprint Single Source of Truth) nõuetele.

---

## 📁 Saadaval Profiilid

1. **`ords-image.yaml`** (id: `app-ords-image`)
   - Ametlikul Oracle OCR konteineripildil (`container-registry.oracle.com/database/ords:latest`) põhinev tsentraalne multi-pool ORDS server.
   - Pordid: HTTP `8088`, HTTPS `8448`.

2. **`ords-local-custom.yaml`** (id: `app-ords-local-custom`)
   - Lokaalne skriptipõhine paigaldus allalaaditud ORDS zip-arhiivist kohalikku failisüsteemi (`/opt/oracle/ords`).
   - Pordid: HTTP `8088`, HTTPS `8448`.

3. **`ords-remote-custom.yaml`** (id: `app-ords-remote-custom`)
   - Kaugserveri ORDS paigaldus SSH vahendusel eraldiseisvasse vahevara serverisse (`remote_host: "ords.internal.local"`).
   - Pordid: HTTP `8088`, HTTPS `8448`.

4. **`ords-standalone.yaml`** (id: `app-ords-standalone`)
   - Eraldiseisev autonoomne ORDS testimiseks isoleeritud portidel `8085` / `8445`.
