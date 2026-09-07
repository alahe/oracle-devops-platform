# Oracle Analytics Publisher Desktop & MS Word Pixel-Perfect Töölaua Juhend

[ 🇬🇧 English ](../publisher-template-builder-guide.md) | [ 🇪🇪 Eesti ](publisher-template-builder-guide.md) | [ 🇫🇮 Suomi ](../fi/publisher-template-builder-guide.md) | [ 🇸🇪 Svenska ](../sv/publisher-template-builder-guide.md) | [ 🇱🇻 Latviešu ](../lv/publisher-template-builder-guide.md) | [ 🇱🇹 Lietuvių ](../lt/publisher-template-builder-guide.md)

---

## 1. Ülevaade ja Ettevõtte Valupunkti Lahendus

Oracle Analytics Publisheri **Pixel-Perfect äridokumentide (arved, saatelehed, finantsaruanded, lepingud)** kujundamine põhineb **Rich Text Format (RTF) mallidel**, mida koostatakse **Microsoft Wordi ja ametliku Oracle Analytics Publisher Desktop (Template Builder for Word) lisandmooduli** abil.

### 🛑 Lahendatud Ettevõtte Pudelikael:
1. **Lukustatud Arvutid (Admin Õiguste Puudumine):** Arendajad ei saa oma tööarvutisse paigaldada `.exe` tarkvara ega Wordi lisandmooduleid.
2. **IT-toe Piletijärjekorrad:** Iga paigaldus või uuendus läbi IT-toe võtab nädalaid.
3. **Platvormiülesus:** **macOS** või **Linux** arvutites puudub ametlik Wordi Template Builder.

### 💡 Podman Konteineri Lahendus (`app-publisher-designer`):
- Käitab **Wordi keskkonda koos ametliku Oracle BI Publisher Desktop lisandmooduliga** otse veebibrauseris läbi **HTML5 noVNC pordil 6083** (`http://localhost:6083/vnc.html`).
- **0 MB Idle RAM:** Vajaduspõhine käivitus – käivitage trükise kujundamisel, sulgege töö lõpus.
- **Otsene Git Sünkroniseerimine:** Wordis salvestatud failid tekivad otse host-arvuti kausta `templates/publisher/`.

---

## 2. Kiiralustus ja Töövoog

### Samm 1: Käivita Disainer-Konteiner
Läbi Blueprint 9 (Soovitatav):
```bash
./scripts/setup-all.sh -b 9
```
Või eraldiseisva skriptiga:
```bash
./scripts/publisher/start-designer.sh
```

### Samm 2: Ava Veebibrauseris
```bash
./scripts/publisher/open-designer.sh
# Või ava brauseris: http://localhost:6083/vnc.html
```

### Samm 3: Kujunda Trükis Wordis
1. Klõpsa Wordi ülemisel menüüribal sakki **Publisher**.
2. Vali **Sample XML** ja ava `/u01/templates/samples/arve_näidisandmed.xml`.
3. Kasuta **Insert $\rightarrow$ Table/Form Wizard** tabelite lisamiseks.
4. Vajuta **Preview $\rightarrow$ PDF**, et näha koheselt genereeritud trükist.
5. Salvesta dokument (`Ctrl+S`).

### Samm 4: Testi Renderdamist Käsurealt
```bash
./scripts/publisher/test-render.sh templates/publisher/samples/arve_eesti_standard.rtf templates/publisher/samples/arve_näidisandmed.xml
```

### Samm 5: Peata Konteiner Mälu Vabastamiseks
```bash
./scripts/publisher/stop-designer.sh
```
