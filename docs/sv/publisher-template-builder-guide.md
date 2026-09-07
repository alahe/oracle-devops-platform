# Oracle Analytics Publisher Desktop & MS Word Pixel-Perfect Arbetsstationsguide

[ 🇬🇧 English ](../publisher-template-builder-guide.md) | [ 🇪🇪 Eesti ](../et/publisher-template-builder-guide.md) | [ 🇫🇮 Suomi ](../fi/publisher-template-builder-guide.md) | [ 🇸🇪 Svenska ](publisher-template-builder-guide.md) | [ 🇱🇻 Latviešu ](../lv/publisher-template-builder-guide.md) | [ 🇱🇹 Lietuvių ](../lt/publisher-template-builder-guide.md)

---

## 1. Översikt och Lösning

Skapandet av **Pixel-Perfect-dokument (fakturor, följesedlar, rapporter)** i Oracle Analytics Publisher baseras på **RTF-mallar** som skapas med **Microsoft Word och det officiella Oracle Analytics Publisher Desktop-tillägget**.

### 💡 Podman Kontainerlösning (`app-publisher-designer`):
- Kör **Word och det officiella Oracle Publisher-tillägget** direkt i webbläsaren via **HTML5 noVNC på port 6083** (`http://localhost:6083/vnc.html`).
- **0 MB Idle RAM:** Startas vid behov och stoppas efter avslutat arbete.
- **Fungerar perfekt på macOS och Linux utan lokala IT-installationer.**

### Snabbkommandon:
```bash
# 1. Starta designmiljö (Blueprint 9 eller skript):
./scripts/setup-all.sh -b 9
# eller: ./scripts/publisher/start-designer.sh
./scripts/publisher/open-designer.sh
./scripts/publisher/test-render.sh templates/publisher/samples/arve_eesti_standard.rtf templates/publisher/samples/arve_naidisandmed.xml
./scripts/publisher/stop-designer.sh
```
