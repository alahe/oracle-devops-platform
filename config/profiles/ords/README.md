[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🌐 ORDS Gateway Profiles (`config/profiles/ords/`)

This directory contains explicit **ORDS (Oracle REST Data Services)** runtime and networking profiles conforming to Rule 11 (Clean Blueprint Single Source of Truth).

## 📂 Available ORDS Profiles
1. **`ords-image.yaml`** (id: `app-ords-image`)
   - Central multi-pool ORDS container based on official Oracle OCR image (`container-registry.oracle.com/database/ords:latest`).
   - Ports: HTTP `8088`, HTTPS `8448`.
2. **`ords-local-custom.yaml`** (id: `app-ords-local-custom`)
   - Local script-based installation unpacked directly inside container filesystem (`/tmp`).
   - Ports: HTTP `8088`, HTTPS `8448`.
3. **`ords-remote-custom.yaml`** (id: `app-ords-remote-custom`)
   - Remote middleware server ORDS gateway routing requests to enterprise databases.
   - Ports: HTTP `8088`, HTTPS `8448`.
4. **`ords-standalone.yaml`** (id: `app-ords-standalone`)
   - Standalone edge proxy for cloud ADB or remote gateways on isolated ports `8085` / `8445`.
