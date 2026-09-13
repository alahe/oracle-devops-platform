# 17. DevOps Vahelehe UX Moderniseerimine, Dokitav Terminal ja Reeglipõhised Command Studiod

- **Staatus:** Heaks kiidetud (Accepted)
- **Kuupäev:** 2026-09-13
- **Otsustajad:** Tarkvara vaneminsener, Ettevõtte arhitekt, Vanem-UX ekspert, Kasutaja
- **Valdkond:** Dev Hub (`docs/dev-hub.html`), DevOps juhtpaneel, Terminali UX, Tehisintellekti sünergia

---

## Kontekst ja Äriline Valupunkt

Platvormi juhtpaneelil Dev Hub (`docs/dev-hub.html`) oli vahekaart `⚡ DevOps` kasvanud 28 eraldiseisva kaardini. Igapäevases arendustöös ilmnesid järgmised kriitilised kitsaskohad:

1. **Kaardisisene logikast (UX Kitsaskoht):**
   Täitmislogi kuvati kitsas 180px kastis otse kaardi sees. Pikemate (mitmesaja-realiste) paigaldus- või lähtestuslogide korral tekitas see tugevat visuaalset ebamugavust, kaardid venisid ebaühtlaselt, puudus võimalus logist otsida (`Ctrl+F`), puudus stopper ja logi kopeerimine oli tülikas.

2. **Käskude dubleerimine ja parameetrite konfliktid:**
   Skriptide `setup-all.sh` ja `reset-all.sh` erinevate parameetrite jaoks oli loodud 8 eraldi kaarti. Kasutajale polnud selge, millised lipud sobivad kokku ja millised välistavad üksteist (nt `--dry-run` vs `--fresh`, või `-s` FastStart vs `--fresh`).

3. **Operatsiooniline turvarisk (Ohutushierarhia puudumine):**
   Pöördumatult andmeid kustutavad käsud (nt `reset-all.sh --system -y`) nägid visuaalselt välja identsed süütute staatusekontrollidega (nt `check-urls.sh`), tekitades riski juhuslikuks andmekaoks.

4. **Tehisintellekti kontekstireostus (Token Economics):**
   Suurte arhitektuuriliste selgituste kopeerimine otse AI oskuste failidesse (`.agents/skills/`) suurendas märgatavalt prompt-tokenite mahtu ja tekitas mudelitel tähelepanuhäireid (*context saturation*).

---

## Arhitektuurne Otsus

Otsustati viia sisse 5 põhimõttelist arhitektuurset ja kasutajakogemuslikku muudatust:

### 1. 3-Tasemeline Adaptiivne Logiliides (Docked Terminal Drawer)
- **Kaardil:** Ainult kompaktne reaalajas olekuriba koos stopperiga (`⏱️ 0:14`) ja staatusemärgiga (`EXIT 0` / `EXIT 1`). Kaart ei veni.
- **Alumine Dokitav Terminal:** Ekraani allosast sujuvalt väljalibisev reguleeritav tume terminal (nagu VS Code'is). Võimaldab jälgida logi ja samal ajal sirvida teisi vahelehti ja teenuste olekut ilma protsessi katkestamata.
- **Täisekraani Fookusrežiim:** Toetab logist otsimist (`Ctrl+F`), ANSI värvikoodide esiletõstu (roheline `OK`, punane `ERROR`/`ORA-*`), auto-scroll lülitit ja otselinki failile `install_logs/...`.

### 2. Guided Constraint-Based Command Studiod
- Asendada korduvad kaardid kahe interaktiivse stuudioga: **Setup Studio** ja **Reset Studio**.
- **Vastastikku välistavad režiimigrupid (Exclusive Radio Pills):** Valikute grupeerimine (nt *Täispaigaldus*, *FastStart*, *Puhas algus*, *Simulatsioon*).
- **Nutikas keelamine (Smart Disabling):** Kui valitakse `FastStart (-s)`, deaktiveeritakse automaatselt `--fresh` koos vihjega põhjuse kohta.
- **Reaalajas mõju kokkuvõte:** Kuvab sünkroonselt tekkiva CLI käsu ja inimkeelse selgituse selle tegelikust toimest.

### 3. Semantiline Ohutushierarhia ja Kinnituskaitse
- Visuaalne värvikood: `🛡️ Ohutu (Roheline)`, `⚡ Tavatoiming (Lilla)`, `⚠️ Kriitiline/Hävitav (Punane/Merevaik)`.
- Hävitavad toimingud nõuavad 2-astmelist kinnitust enne teostamist.

### 4. AI Assistentide Sünergia (Copilot & Antigravity 1-Click Remediation)
- Kui käsk ebaõnnestub, pakub terminal nuppu `🤖 Küsi AI-lt lahendust`, mis avab eelseadistatud küsimuse ja vealogiga Dev Hubi Copiloti/Antigravity sahtli.

### 5. Otsuste Talletamine ja Saledad Lepingud (Thin Contract Pattern)
- Kogu põhjalik äri- ja tehniline tagapõhi talletatakse ADR-is (`docs/adr/`) ja tootespetsifikatsioonis (`docs/specs/`).
- AI oskuste failid (`.agents/skills/`) hoitakse saledad (max 8–10 rida), viidates otse ADR-ile.
- Kaust `install_logs/` jääb rangelt kohalikuks ja `.gitignore` alla (Reegel 1.2).

---

## Tagajärjed ja Kasu

### Positiivne mõju:
1. **Developer Experience (DX):** Arendaja saab käivitada ja jälgida protsesse ilma kognitiivse ülekoormuseta; logide sirvimine on mugav ja informatiivne.
2. **Operatsiooniline turvalisus:** Juhuslike süsteemipuhastuste risk on viidud miinimumini tänu kinnituskaitsele.
3. **Porditavus ja Null-Sõltuvus:** Lahendus kasutab natiivset Vanilla JS-i, CSS-i ja Pythoni standardteeki ilma väliste sõltuvusteta.
4. **AI efektiivsus:** AI oskused ei raiska tokeneid, kuid säilitavad täieliku arhitektuurse mälu.

### Piirangud ja järelevalve:
- Logipuhver brauseris on piiratud 1500 reaga (ring-buffer), et vältida brauseri mälu hangumist. Täielik logi on alati kättesaadav lokaalsel kettal kaustas `install_logs/`.
