[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Pakendatud APEX Rakendused (`applications/`)

See kataloog on ette nähtud deklaratiivsete Oracle APEX rakenduste hoidmiseks, mis on defineeritud [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/) abil või standardsete SQLcl split-eksportidena.

---

## 🚀 Kasutamine

1. **Rakenduste paigutamine:** Aseta kohandatud rakenduste paketid siia (nt `applications/minu_rakendus/application.apx`).
2. **Automaatne tarne:** Skripti `./scripts/setup-all.sh` käivitamisel skaneerib tarnemootor (`scripts/internal/deploy-apex-apps.sh`) selle kataloogi ja impordib kehtivad APEX rakendused sihttööalasse.
3. **Valideerimine:**
   ```bash
   node .agents/skills/apexlang/tools/apexctl.mjs apexlang validate --app-path applications/<rakenduse_nimi>
   ```

> [!NOTE]
> **TO-BE Teekaart:** Täielikult deklaratiivne andmebaasisisene APEX versioon DevHubist (App 101) on kavandatud tulevikuks. Kõik tööriistad, APEXlang kompilaatorid ja tarnekonveierid on eelseadistatud.
