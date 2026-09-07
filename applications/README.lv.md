[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Pakotās APEX lietotnes (`applications/`)

Šis direktorijs ir paredzēts deklaratīvām Oracle APEX lietotnēm, kas definētas, izmantojot [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/) vai standarta SQLcl dalītos eksportus.

---

## 🚀 Lietošana

1. **Lietotņu izvietošana:** Novietojiet pielāgotu lietotņu pakotnes šeit (piemēram, `applications/mana_lietotne/application.apx`).
2. **Automatizēta ieviešana:** Skripta `./scripts/setup-all.sh` izpildes laikā izvietošanas dzinējs (`scripts/internal/deploy-apex-apps.sh`) skenē šo mapi un importē derīgas APEX lietotnes mērķa darba vietā.
3. **Validācija:**
   ```bash
   node .agents/skills/apexlang/tools/apexctl.mjs apexlang validate --app-path applications/<lietotnes_nosaukums>
   ```

> [!NOTE]
> **TO-BE Plāns:** Pilnībā deklaratīva datubāzes APEX versija no DevHub (App 101) ir plānota nākotnē. Visi rīki, APEXlang kompilatori un ieviešanas konveijeri ir iepriekš nokonfigurēti.
