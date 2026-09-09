[ 🇬🇧 English ](../apex-apps-deployment.md) | [ 🇪🇪 Eesti ](../et/apex-apps-deployment.md) | [ 🇫🇮 Suomi ](../fi/apex-apps-deployment.md) | [ 🇸🇪 Svenska ](../sv/apex-apps-deployment.md) | [ 🇱🇻 Latviešu ](apex-apps-deployment.md) | [ 🇱🇹 Lietuvių ](../lt/apex-apps-deployment.md)

# Automatizēta APEX lietotņu izvietošana

Datu bāzes uzstādīšanas laikā platforma atbalsta pilnībā automatizētu vairāku Oracle APEX lietotņu importu, darba vietas konfigurēšanu un dzīves cikla pārvaldību.

---

## Lietotņu izvietošanas darbplūsma

1. **Lietotņu krātuve:**
   Ievietojiet instalējamās APEX lietotņu datnes (gan standarta `.sql` eksportus, gan deklaratīvās **APEXlang** `.apx` / `.apex` datnes) direktorijā `binaries/apex_apps/`.
2. **Importa skripts (`deploy-apex-apps.sh`):**
   Iekšējais palīgskripts **[`scripts/internal/deploy-apex-apps.sh`](../../scripts/internal/deploy-apex-apps.sh)** secīgi instalē lietotnes APEX vidē, automātiski iestatot mērķa darba telpu (`PROXY_WORKSPACE`) un shēmu (`APEX_PROXY_SCHEMA`).
3. **Setup-all integrācija (8. solis):**
   Galvenais vides uzstādīšanas skripts `./scripts/setup-all.sh` automātiski izpilda šo soli. Lietotņu izvietošanu var pilnībā izlaist, izmantojot parametru `--no-monitor-app` (vai konfigurējot mainīgo `.env` datnē).

---

## Izstrāde un versiju pārvaldība (APEXlang + AI Skill)

APEX lietotnes (piemēram, monitoringa paneli) tiek izstrādātas atsevišķās krātuvēs. Izstrādes procesā ieteicams izmantot Oracle APEX AI prasmi **`oracle/skills/apex`**, kas palīdz mākslīgā intelekta aģentiem lasīt un labot teksta bāzēto APEXlang sintaksi, nodrošinot tīru un versijotu kodu.

> [!TIP]
> **Deklaratīvās blueprint specifikācijas pret masveida koda uzturēšanas slogu:**
> APEX blueprints un APEXlang (`.apx`) kalpo kā deklaratīvas specifikācijas. Milzīgas ģenerēta koda bāzes uzturēšanas vietā (kur izstrādātājiem jāuztur 10 000+ koda rindu) datubāzē iebūvētā drošība un 0 ms latentums nodrošina ātrāku un būtiski drošāku piegādi bez koda novecošanās riska.
