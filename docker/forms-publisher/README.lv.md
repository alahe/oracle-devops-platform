[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Apvienotais Oracle Forms 14c + Analytics Publisher konteiners (`docker/forms-publisher/`)

Šis direktorijs būvē **Apvienoto FMW 14c Izpildlaika Konteineru** (`localhost/oracle-forms-publisher:14c-2025`), kas darbina Forms 14.1.2 un Publisher 2025 vienā WebLogic domēnā.

## Galvenās Priekšrocības
- **50% Atmiņas Ietaupījums:** Patērē ~2.5 GB RAM divu atsevišķu instanču ~4.5 GB vietā.
- **Vienota Infrastruktūra:** Atkārtoti izmanto to pašu JDK 17 un WebLogic.
- **Porti:** 9001 (Forms), 9502 (Publisher), 6082 (noVNC Forms Builder), 7001 (AdminConsole).
