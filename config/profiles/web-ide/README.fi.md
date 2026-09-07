[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 💻 Web-IDE-Palvelun Profiilit (`config/profiles/web-ide/`)

Tämä hakemisto sisältää YAML-profiilit **Web-IDE (`code-server`)** -palvelun määrittämiseen.

## 📂 Web-IDE-Profiilien Matriisi

| Profiilitiedosto | Profiilin ID | Kuvaus | Sisältyvät Työkalut | Oletus Blueprintissä |
| :--- | :--- | :--- | :--- | :--- |
| **`web-ide-standard.yaml`** | `web-ide-standard` | **🌟 Kattava Yritystyöasema (Oletus)** | Google Antigravity AI, Oracle SQL Developer, Python Suite, GitHub Actions, act runner, gh CLI, SQLcl, OpenJDK 21 | **BP 8** |
| **`web-ide-minimal.yaml`** | `web-ide-minimal` | **Kevyt VS Code -ympäristö** | Puhdas `code-server` ja OpenJDK 21 | Valinnainen (pieni RAM) |
| **`web-ide-disabled.yaml`** | `web-ide-disabled` | **Palvelu Pois Käytöstä** | Web-IDE pois päältä (`enabled: false`) | Erilliset DB-mallit |
