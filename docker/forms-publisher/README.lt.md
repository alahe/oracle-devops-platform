[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Sujungtas Oracle Forms 14c + Analytics Publisher Konteineris (`docker/forms-publisher/`)

Šiame kataloge kuriamas **Sujungtas FMW 14c Vykdymo Konteineris** (`localhost/oracle-forms-publisher:14c-2025`), vykdantis Forms 14.1.2 ir Publisher 2025 tame pačiame WebLogic domene.

## Pagrindiniai Privalumai
- **50% Atminties Sutaupymas:** Naudoja ~2.5 GB RAM vietoj ~4.5 GB dviem atskiriems egzemplioriams.
- **Vieninga Infrastruktūra:** Pakartotinai naudoja tą patį JDK 17 ir WebLogic.
- **Prievadai:** 9001 (Forms), 9502 (Publisher), 6082 (noVNC Forms Builder), 7001 (AdminConsole).
