# APEX Rakenduste Automaatne Paigaldamine

Andmebaasi seadistamisel toetab projekt mitme APEX rakenduse täielikult automatiseeritud importi.

---

## Rakenduste paigaldamise sammud

1.  **Rakenduste hoidmine:**
    Kopeeri oma paigaldatavad APEX rakenduste failid (sobivad nii tavalised `.sql` ekspordid kui ka uued **APEXlang** `.apex` failid) kataloogi `binaries/apex_apps/`.
2.  **Importskript (`deploy-apex-apps.sh`):**
    Sisemine abiskript **[scripts/internal/deploy-apex-apps.sh](../scripts/internal/deploy-apex-apps.sh)** teostab failide järjestikuse paigalduse APEX-isse, seadistades importimisel automaatselt siht-tööruumi (`PROXY_WORKSPACE`) ja skeemi (`APEX_PROXY_SCHEMA`).
3.  **Setup-all integratsioon (Samm 8):**
    Keskkonna loomise skript `./scripts/setup-all.sh` käivitab selle sammu automaatselt. Rakenduste paigaldamise saab täielikult vahele jätta parameetriga `--no-monitor-app` (või seadistades keskkonnamuutuja `.env` failis).

---

## Arendus ja versioonihaldus (APEXlang + AI Skill)

APEX rakendusi (nagu monitooringu dashboard) arendatakse iseseisvates repositooriumides. Arenduses on soovitatav kasutada Oracle APEX AI skilli **`oracle/skills/apex`**, mis juhendab tehisintellekti agente APEXlang tekstipõhise süntaksi muutmisel ja loomisel, tagades loetava ja versioonitava koodibaasi.

> [!TIP]
> **Deklaratiivsed blueprint-spetsifikatsioonid vs toorkoodi haldamise koormus:**
> APEX blueprints ja APEXlang (`.apx`) toimivad kui deklaratiivsed spetsifikatsioonid. Koodi massilise genereerimise asemel (kus arendustiim peab omama ja hooldama 10 000+ rida genereeritud liimkoodi) tagab andmebaasi sisse ehitatud turvalisus ja 0ms latentsus kiirema ja oluliselt turvalisema tarne ilma koodi roiskumise ohuta.
