[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Unified Oracle Forms 14c + Analytics Publisher Container (`docker/forms-publisher/`)

This directory builds the **Unified FMW 14c Runtime Container** (`localhost/oracle-forms-publisher:14c-2025`), running Oracle Forms 14.1.2 and Analytics Publisher 2025 inside a single WebLogic domain.

## Key Benefits
- **50% Memory Reduction:** Consumes ~2.5 GB RAM instead of ~4.5 GB for two separate WebLogic instances.
- **Unified Infrastructure:** Reuses the same JDK 17 and WebLogic runtime.
- **Ports:** 9001 (Forms), 9502 (Publisher xmlpserver), 6082 (noVNC HTML5 Forms Builder), 7001 (AdminConsole).
