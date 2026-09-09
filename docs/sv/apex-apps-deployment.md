[ 🇬🇧 English ](../apex-apps-deployment.md) | [ 🇪🇪 Eesti ](../et/apex-apps-deployment.md) | [ 🇫🇮 Suomi ](../fi/apex-apps-deployment.md) | [ 🇸🇪 Svenska ](apex-apps-deployment.md) | [ 🇱🇻 Latviešu ](../lv/apex-apps-deployment.md) | [ 🇱🇹 Lietuvių ](../lt/apex-apps-deployment.md)

# Automatisk driftsättning av APEX-applikationer

Under databaskonfigurationen stöder plattformen helautomatisk import, arbetsytetilldelning och livscykelhantering för flera Oracle APEX-applikationer.

---

## Arbetsflöde för applikationsdriftsättning

1. **Applikationslagring:**
   Placera dina installerbara APEX-applikationsfiler (både vanliga `.sql`-exporter och deklarativa **APEXlang** `.apx` / `.apex`-filer) i katalogen `binaries/apex_apps/`.
2. **Importskript (`deploy-apex-apps.sh`):**
   Det interna automatiseringsskriptet **[`scripts/internal/deploy-apex-apps.sh`](../../scripts/internal/deploy-apex-apps.sh)** installerar applikationerna sekventiellt i APEX och konfigurerar automatiskt målarbetsytan (`PROXY_WORKSPACE`) och schemat (`APEX_PROXY_SCHEMA`).
3. **Setup-all integration (Steg 8):**
   Miljöskriptet `./scripts/setup-all.sh` kör detta steg automatiskt. Installationen av applikationer kan hoppas över helt med flaggan `--no-monitor-app` (eller via miljövariabel i `.env`-filen).

---

## Utveckling och versionshantering (APEXlang + AI Skill)

APEX-applikationer (såsom övervakningspaneler och företagsverktyg) utvecklas i separata arkiv. För aktiv utveckling rekommenderas Oracle APEX AI Skill **`oracle/skills/apex`**, som vägleder AI-agenter vid skapande och ändring av deklarativ APEXlang-syntax för ren versionshantering.

> [!TIP]
> **Deklarativa blueprint-specifikationer kontra underhållsbörda av råkod:**
> APEX blueprints och APEXlang (`.apx`) fungerar som deklarativa specifikationer. Istället för att generera enorma kodbaser (där utvecklingsteamet tvingas underhålla över 10 000 rader genererad limkod) garanterar databasens inbyggda säkerhet och 0 ms latens snabbare och säkrare leverans utan teknisk skuld.
