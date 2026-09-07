[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 💻 Web IDE Paslaugos Profiliai (`config/profiles/web-ide/`)

Šiame kataloge yra YAML profiliai **Web IDE (`code-server`)** paslaugai.

## 📂 Web IDE Profilių Matrica

| Profilio Failas | Profilio ID | Aprašymas | Įrankiai ir Plėtiniai | Numatytasis Blueprints |
| :--- | :--- | :--- | :--- | :--- |
| **`web-ide-standard.yaml`** | `web-ide-standard` | **🌟 Universali Įmonės Darbo Vieta (Numatytasis)** | Google Antigravity AI, Oracle SQL Developer, Python Suite, GitHub Actions, act runner, gh CLI, SQLcl, OpenJDK 21 | **BP 8** |
| **`web-ide-minimal.yaml`** | `web-ide-minimal` | **Lengva VS Code Aplinka** | Grynas `code-server` ir OpenJDK 21 | Pasirinktinis (mažai RAM) |
| **`web-ide-disabled.yaml`** | `web-ide-disabled` | **Paslauga Išjungta** | Web IDE išjungtas (`enabled: false`) | Atskiri DB brėžiniai |
