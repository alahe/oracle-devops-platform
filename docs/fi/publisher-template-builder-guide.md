# Oracle analytics Publisher desktop & MS Word pixel-perfect -työaseman opas

[ 🇬🇧 English ](../publisher-template-builder-guide.md) | [ 🇪🇪 Eesti ](../et/publisher-template-builder-guide.md) | [ 🇫🇮 Suomi ](publisher-template-builder-guide.md) | [ 🇸🇪 Svenska ](../sv/publisher-template-builder-guide.md) | [ 🇱🇻 Latviešu ](../lv/publisher-template-builder-guide.md) | [ 🇱🇹 Lietuvių ](../lt/publisher-template-builder-guide.md)

---

## 1. Yleiskatsaus ja ongelmanratkaisu

Oracle Analytics Publisherin **Pixel-Perfect -liiketoimintatulosteiden (laskut, lähetteet, raportit)** suunnittelu perustuu **RTF-malleihin**, joita luodaan **Microsoft Wordilla ja virallisella Oracle Analytics Publisher Desktop (Template Builder for Word) -lisäosalla**.

### 💡 Podman-konttiratkaisu (`app-publisher-designer`):
- Ajaa **Word-ympäristöä ja virallista Oracle Publisher -lisäosaa** suoraan selaimessa **HTML5 noVNC -portissa 6083** (`http://localhost:6083/vnc.html`).
- **0 MB Idle RAM:** Käynnistetään tarvittaessa ja sammutetaan työn päätyttyä.
- **Toimii suoraan macOS:ssä ja Linuxissa ilman paikallisia asennuksia.**

### Pikakomennot:
```bash
# 1. Käynnistä suunnitteluympäristö (Blueprint 9 tai skripti):
./scripts/setup-all.sh -b 9
# tai: ./scripts/publisher/start-designer.sh

# 2. Avaa selaimessa:
./scripts/publisher/open-designer.sh

# 3. Testaa PDF-renderöintiä:
./scripts/publisher/test-render.sh templates/publisher/samples/arve_eesti_standard.rtf templates/publisher/samples/arve_naidisandmed.xml

# 4. Pysäytä kontti:
./scripts/publisher/stop-designer.sh
```
