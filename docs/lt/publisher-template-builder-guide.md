# Oracle Analytics Publisher Desktop & MS Word Pixel-Perfect Darbo Vietos Vadovas

[ 🇬🇧 English ](../publisher-template-builder-guide.md) | [ 🇪🇪 Eesti ](../et/publisher-template-builder-guide.md) | [ 🇫🇮 Suomi ](../fi/publisher-template-builder-guide.md) | [ 🇸🇪 Svenska ](../sv/publisher-template-builder-guide.md) | [ 🇱🇻 Latviešu ](../lv/publisher-template-builder-guide.md) | [ 🇱🇹 Lietuvių ](publisher-template-builder-guide.md)

---

## 1. Apžvalga ir Sprendimas

Oracle Analytics Publisher **Pixel-Perfect dokumentų (sąskaitų faktūrų, važtaraščių, ataskaitų)** kūrimas remiasi **RTF šablonais**, kuriais manipuliuojama **Microsoft Word ir oficialiu Oracle Analytics Publisher Desktop papildiniu**.

### 💡 Podman Konteinerio Sprendimas (`app-publisher-designer`):
- Paleidžia **Word ir oficialų Oracle Publisher papildinį** tiesiogiai naršyklėje per **HTML5 noVNC prievadą 6083** (`http://localhost:6083/vnc.html`).
- **0 MB Idle RAM:** Paleidžiama pagal poreikį.
- **Veikia macOS ir Linux be vietinių diegimų ar IT administratoriaus teisių.**

### Greitosios komandos:
```bash
# 1. Paleisti dizaino aplinką (Blueprint 9 arba scenarijus):
./scripts/setup-all.sh -b 9
# arba: ./scripts/publisher/start-designer.sh
./scripts/publisher/open-designer.sh
./scripts/publisher/test-render.sh templates/publisher/samples/arve_eesti_standard.rtf templates/publisher/samples/arve_naidisandmed.xml
./scripts/publisher/stop-designer.sh
```
