[ 🇬🇧 English ](../apex-apps-deployment.md) | [ 🇪🇪 Eesti ](../et/apex-apps-deployment.md) | [ 🇫🇮 Suomi ](../fi/apex-apps-deployment.md) | [ 🇸🇪 Svenska ](../sv/apex-apps-deployment.md) | [ 🇱🇻 Latviešu ](../lv/apex-apps-deployment.md) | [ 🇱🇹 Lietuvių ](apex-apps-deployment.md)

# Automatizuotas APEX programų diegimas

Duomenų bazės konfigūravimo metu platforma palaiko visiškai automatizuotą kelių Oracle APEX programų importavimą, darbo srities priskyrimą ir gyvavimo ciklo valdymą.

---

## Programų diegimo eiga

1. **Programų saugykla:**
   Nukopijuokite diegiamus APEX programų failus (tinka tiek standartiniai `.sql` eksportai, tiek deklaratyvūs **APEXlang** `.apx` / `.apex` failai) į katalogą `binaries/apex_apps/`.
2. **Importo scenarijus (`deploy-apex-apps.sh`):**
   Vidinis pagalbinis scenarijus **[`scripts/internal/deploy-apex-apps.sh`](../../scripts/internal/deploy-apex-apps.sh)** nuosekliai diegia programas į APEX, automatiškai nustatydamas tikslinę darbo sritį (`PROXY_WORKSPACE`) ir schemą (`APEX_PROXY_SCHEMA`).
3. **Setup-all integracija (8 žingsnis):**
   Aplinkos diegimo scenarijus `./scripts/setup-all.sh` automatiškai paleidžia šį žingsnį. Programų diegimą galima praleisti nurodžius parametrą `--no-monitor-app` (arba nustačius aplinkos kintamąjį `.env` faile).

---

## Kūrimas ir versijų valdymas (APEXlang + AI Skill)

APEX programos (pvz., stebėjimo skydelis) kuriamos atskirose saugyklose. Kūrimo procese rekomenduojama naudoti Oracle APEX AI įgūdį **`oracle/skills/apex`**, kuris padeda DI agentams skaityti ir keisti tekstinę APEXlang sintaksę, užtikrinant skaidrią versijų kontrolę.

> [!TIP]
> **Deklaratyvios blueprint specifikacijos prieš rankinio kodo palaikymo naštą:**
> APEX blueprints ir APEXlang (`.apx`) veikia kaip deklaratyvios specifikacijos. Vietoj didžiulių sugeneruoto kodo bazių kūrimo (kur inžinieriai turi prižiūrėti virš 10 000 sugeneruoto kodo eilučių), duomenų bazėje integruotas saugumas ir 0 ms delsa užtikrina greitesnį ir žymiai saugesnį pristatymą be techninės skolos.
