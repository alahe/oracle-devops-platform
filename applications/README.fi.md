[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Paketoidut APEX-Sovellukset (`applications/`)

Tämä hakemisto on tarkoitettu deklaratiivisille Oracle APEX -sovelluksille, jotka on määritelty käyttäen [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/) -kieltä tai SQLcl:n split-vientejä.

---

## 🚀 Käyttö

1. **Sovellusten sijoittaminen:** Aseta mukautetut sovelluspaketit tähän hakemistoon (esim. `applications/oma_sovellus/application.apx`).
2. **Automaattinen käyttöönotto:** Komentosarjan `./scripts/setup-all.sh` aikana käyttöönottomoottori (`scripts/internal/deploy-apex-apps.sh`) skannaa hakemiston ja tuo kelvolliset APEX-sovellukset työtilaan.
3. **Validointi:**
   ```bash
   node .agents/skills/apexlang/tools/apexctl.mjs apexlang validate --app-path applications/<sovelluksen_nimi>
   ```

> [!NOTE]
> **TO-BE Tiekartta:** Täysin deklaratiivinen tietokantapohjainen APEX-versio DevHubista (App 101) on suunniteltu tulevaksi. Kaikki työkalut, APEXlang-kääntäjät ja käyttöönottoputket ovat valmiina.
