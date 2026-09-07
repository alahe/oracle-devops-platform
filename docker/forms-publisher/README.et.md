[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Koondatud Oracle Forms 14c + Analytics Publisher Konteiner (`docker/forms-publisher/`)

See kataloog ehitab **Ühtse FMW 14c Käituskonteineri** (`localhost/oracle-forms-publisher:14c-2025`), mis käitab Oracle Forms 14.1.2 ja Analytics Publisher 2025 samas WebLogic domeenis.

## Peamised Eelised
- **50% Mälusääst:** Tarbib ~2.5 GB RAM-i kahe eraldi WebLogic instantsi ~4.5 GB asemel.
- **Ühtne Infrastruktuur:** Taaskasutab sama JDK 17 ja WebLogic käitust.
- **Pordid:** 9001 (Forms), 9502 (Publisher xmlpserver), 6082 (noVNC HTML5 Forms Builder), 7001 (AdminConsole).
