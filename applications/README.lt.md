[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Supakuotos APEX Programos (`applications/`)

Šis katalogas skirtas deklaratyvioms Oracle APEX programoms, apibrėžtoms naudojant [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/) arba standartinius SQLcl eksportus.

---

## 🚀 Naudojimas

1. **Programų talpinimas:** Talpinkite pasirinktinius programų paketus čia (pvz., `applications/mano_programa/application.apx`).
2. **Automatizuotas diegimas:** Vykdant `./scripts/setup-all.sh`, diegimo variklis (`scripts/internal/deploy-apex-apps.sh`) nuskenuoja šį katalogą ir importuoja tinkamas APEX programas į darbo erdvę.
3. **Patvirtinimas:**
   ```bash
   node .agents/skills/apexlang/tools/apexctl.mjs apexlang validate --app-path applications/<programos_pavadinimas>
   ```

> [!NOTE]
> **TO-BE Gairės:** Visiškai deklaratyvi duomenų bazės APEX versija iš DevHub (App 101) suplanuota ateičiai. Visi įrankiai, APEXlang kompiliatoriai ir diegimo grandinės yra paruošti.
