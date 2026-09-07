[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Paketerade apex-applikationer (`applications/`)

Denna katalog är avsedd för deklarativa Oracle APEX-applikationer som definierats med [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/) eller SQLcl split-exporter.

---

## 🚀 Användning

1. **Placera applikationer:** Placera anpassade applikationspaket här (t.ex. `applications/min_app/application.apx`).
2. **Automatiserad driftsättning:** Under `./scripts/setup-all.sh` skannar driftsättningsmotorn (`scripts/internal/deploy-apex-apps.sh`) katalogen och importerar giltiga APEX-applikationer till målarbetsytan.
3. **Validering:**
   ```bash
   node .agents/skills/apexlang/tools/apexctl.mjs apexlang validate --app-path applications/<app_namn>
   ```

> [!NOTE]
> **TO-BE Färdplan:** En fullständigt deklarativ databasversion av DevHub (App 101) planeras för framtiden. Alla verktyg, APEXlang-kompilatorer och driftsättningspipelines är förkonfigurerade.
