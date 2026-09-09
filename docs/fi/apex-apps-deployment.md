[ 🇬🇧 English ](../apex-apps-deployment.md) | [ 🇪🇪 Eesti ](../et/apex-apps-deployment.md) | [ 🇫🇮 Suomi ](apex-apps-deployment.md) | [ 🇸🇪 Svenska ](../sv/apex-apps-deployment.md) | [ 🇱🇻 Latviešu ](../lv/apex-apps-deployment.md) | [ 🇱🇹 Lietuvių ](../lt/apex-apps-deployment.md)

# APEX-sovellusten automaattinen käyttöönotto

Tietokannan alustuksen aikana alusta tukee useiden Oracle APEX -sovellusten täysin automatisoitua tuontia ja elinkaaren hallintaa.

---

## Sovellusten käyttöönottovaiheet

1. **Sovellusten tallennus:**
   Kopioi asennettavat APEX-sovellustiedostot (sekä perinteiset `.sql`-viennit että uudet **APEXlang** `.apx` / `.apex` -tiedostot) hakemistoon `binaries/apex_apps/`.
2. **Tuontikomento (`deploy-apex-apps.sh`):**
   Sisäinen apuskripti **[`scripts/internal/deploy-apex-apps.sh`](../../scripts/internal/deploy-apex-apps.sh)** asentaa sovellukset järjestyksessä APEXiin ja määrittää automaattisesti kohdetyötilan (`PROXY_WORKSPACE`) ja skeeman (`APEX_PROXY_SCHEMA`).
3. **Setup-all integraatio (Vaihe 8):**
   Ympäristön asennusskripti `./scripts/setup-all.sh` suorittaa tämän vaiheen automaattisesti. Sovellusten asennus voidaan ohittaa kokonaan parametrilla `--no-monitor-app` (tai määrittämällä ympäristömuuttuja `.env`-tiedostossa).

---

## Kehitys ja versionhallinta (APEXlang + AI Skill)

APEX-sovelluksia (kuten valvontakoontinäyttöjä) kehitetään itsenäisissä repositorioissa. Kehityksessä suositellaan käytettäväksi Oracle APEX AI -taitoa **`oracle/skills/apex`**, joka ohjaa tekoälyagentteja tekstipohjaisen APEXlang-syntaksin luomisessa ja muokkaamisessa varmistaen selkeän versionhallinnan.

> [!TIP]
> **Deklaratiiviset blueprint-määritykset vs. raakakoodin ylläpitotaakka:**
> APEX-blueprintit ja APEXlang (`.apx`) toimivat deklaratiivisina määrityksinä. Sen sijaan, että generoisi valtavia koodimassoja (joissa kehitystiimin on ylläpidettävä yli 10 000 riviä generoitua liimakoodia), tietokantaan sisäänrakennettu tietoturva ja 0 ms:n viive takaavat nopeamman ja huomattavasti turvallisemman toimituksen ilman koodivelkaa.
