[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Yhdistetty Oracle Forms 14c + Analytics Publisher -säilö (`docker/forms-publisher/`)

Tämä hakemisto rakentaa **Yhdistetyn FMW 14c -Suoritusympäristön** (`localhost/oracle-forms-publisher:14c-2025`), joka suorittaa Forms 14.1.2:ta ja Analytics Publisher 2025:tä samassa WebLogic-toimialueessa.

## Tärkeimmät Edut
- **50% Muistinsäästö:** Kuluttaa ~2.5 GB RAM-muistia kahden erillisen WebLogic-ilmentymän ~4.5 GB:n sijasta.
- **Yhdistetty Infrastruktuuri:** Uudelleenkäyttää saman JDK 17:n ja WebLogicin.
- **Portit:** 9001 (Forms), 9502 (Publisher), 6082 (noVNC Forms Builder), 7001 (AdminConsole).
