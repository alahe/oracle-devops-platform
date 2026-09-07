[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🌐 Profiler för ORDS Gateway (`config/profiles/ords/`)

Denna katalog innehåller explicita profiler för **ORDS (Oracle REST Data Services)** enligt Regel 11.

## 📂 Tillgängliga Profiler
1. **`ords-image.yaml`** (id: `app-ords-image`)
   - Central multi-pool ORDS-server baserad på officiell Oracle OCR-avbildning.
   - Portar: HTTP `8088`, HTTPS `8448`.
2. **`ords-local-custom.yaml`** (id: `app-ords-local-custom`)
   - Lokal skriptbaserad installation inuti behållaren (`/tmp`).
   - Portar: HTTP `8088`, HTTPS `8448`.
3. **`ords-remote-custom.yaml`** (id: `app-ords-remote-custom`)
   - Fjärrserver ORDS-gateway för företagsdatabaser.
   - Portar: HTTP `8088`, HTTPS `8448`.
4. **`ords-standalone.yaml`** (id: `app-ords-standalone`)
   - Fristående ORDS på isolerade portar `8085` / `8445`.
