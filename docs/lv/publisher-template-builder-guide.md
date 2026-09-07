# Oracle Analytics Publisher Desktop & MS Word Pixel-Perfect Darbstacijas Rokasgrāmata

[ 🇬🇧 English ](../publisher-template-builder-guide.md) | [ 🇪🇪 Eesti ](../et/publisher-template-builder-guide.md) | [ 🇫🇮 Suomi ](../fi/publisher-template-builder-guide.md) | [ 🇸🇪 Svenska ](../sv/publisher-template-builder-guide.md) | [ 🇱🇻 Latviešu ](publisher-template-builder-guide.md) | [ 🇱🇹 Lietuvių ](../lt/publisher-template-builder-guide.md)

---

## 1. Pārskats un Risinājums

Oracle Analytics Publisher **Pixel-Perfect dokumentu (rēķinu, pavadzīmju, atskaišu)** izstrāde balstās uz **RTF veidnēm**, ko veido **Microsoft Word ar oficiālo Oracle Analytics Publisher Desktop spraudni**.

### 💡 Podman Konteinera Risinājums (`app-publisher-designer`):
- Nodrošina **Word un oficiālo Oracle Publisher spraudni** tieši tīmekļa pārlūkā caur **HTML5 noVNC portā 6083** (`http://localhost:6083/vnc.html`).
- **0 MB Idle RAM:** Ieslēdzams tikai nepieciešamības gadījumā.
- **Darbojas macOS un Linux bez lokālas programmatūras instalēšanas.**

### Ātrās komandas:
```bash
# 1. Palaist dizaina vidi (Blueprint 9 vai skripts):
./scripts/setup-all.sh -b 9
# vai: ./scripts/publisher/start-designer.sh
./scripts/publisher/open-designer.sh
./scripts/publisher/test-render.sh templates/publisher/samples/arve_eesti_standard.rtf templates/publisher/samples/arve_näidisandmed.xml
./scripts/publisher/stop-designer.sh
```
