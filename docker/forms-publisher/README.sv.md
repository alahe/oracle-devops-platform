[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Konsoliderad Oracle Forms 14c + Analytics Publisher container (`docker/forms-publisher/`)

Denna katalog bygger **Enhetlig FMW 14c Runtime-Container** (`localhost/oracle-forms-publisher:14c-2025`) som kör Forms 14.1.2 och Publisher 2025 inom en enda WebLogic-domän.

## Fördelar
- **50% Minnesminskning:** Förbrukar ~2.5 GB RAM istället för ~4.5 GB för två separata instanser.
- **Enhetlig Infrastruktur:** Återanvänder samma JDK 17 och WebLogic.
- **Portar:** 9001 (Forms), 9502 (Publisher), 6082 (noVNC Forms Builder), 7001 (AdminConsole).
