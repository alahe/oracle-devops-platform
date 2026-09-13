[ 🇬🇧 English ](../devhub-copilot-assistant.md) | [ 🇪🇪 Eesti ](../et/devhub-copilot-assistant.md) | [ 🇫🇮 Suomi ](../fi/devhub-copilot-assistant.md) | [ 🇸🇪 Svenska ](../sv/devhub-copilot-assistant.md) | [ 🇱🇻 Latviešu ](../lv/devhub-copilot-assistant.md) | [ 🇱🇹 Lietuvių ](devhub-copilot-assistant.md)

# 🤖 Dev Hub Daugiatinklis AI asistentas (Copilot + Antigravity) ir Zero-Trust RAG vadovas

Šis vadovas dokumentuoja Developer Hub (`docs/dev-hub.html`) integruotą **daugiatinklį AI asistentą**, palaikantį tiek **GitHub Copilot**, tiek **Google Antigravity**, 5 Taisyklės Zero-Trust saugumo kontrolę, autonominę vietinę žinių bazę ir 1-spustelėjimo tiltus į „VS Code Copilot Chat“ bei „Antigravity“.

---

## 🏛️ 1. Techninė architektūra ir duomenų srautas

Asistentas naudoja dviejų variklių architektūrą su sparčiuoju klavišu `⌘J` / `Ctrl+J`, užtikrinančią greitą perjungimą tarp GitHub Copilot ir Google Antigravity:

```mermaid
flowchart TD
    subgraph UI ["🖥️ Developer Hub<br/>Vartotojo Sąsaja (dev-hub.html)"]
        TRIGGER["Skrajojantis Mygtukas<br/>arba Spartusis Klavišas ⌘J / Ctrl+J"]
        DRAWER["AI Šoninis Skydelis<br/>(Variklio Perjungiklis & Pokalbiai)"]
        VSLINK["1-Spustelėjimo VS Code Mygtukas<br/>(Gilioji Nuoroda & Iškarpinė)"]
        AGYLINK["1-Spustelėjimo Antigravity Mygtukas<br/>(antigravity:// & Iškarpinė)"]
    end

    subgraph Bridge ["⚡ Vietinis Tiltas (dev-hub-bridge.py :8089)"]
        C_STATUS["GET /api/ai/status<br/>(Copilot & Antigravity Patikra)"]
        C_CHAT["POST /api/ai/chat<br/>(Išmanusis RAG & Išvalymas)"]
        C_DEEP["POST /api/ai/deeplink<br/>(Sugeneruoja URI & Kontekstą)"]
    end

    subgraph Security ["🔒 Zero-Trust Variklis (copilot.py)"]
        SANITIZER["Regex Paslapčių Maskavimas<br/>(Slaptažodžiai, Raktai, Piniginės)"]
        RAG["Išmanusis RAG Išrinkiklis<br/>(Blueprint, Dokumentai, 1500 Žetonų)"]
    end

    subgraph Providers ["⚙️ Vykdymo Varikliai"]
        COPILOT_API["GitHub Models / Copilot API<br/>(gpt-4o su atminties žetonu)"]
        AGY_CLI["Google Antigravity Variklis<br/>(Vietinis agy CLI vykdymas)"]
        OFFLINE["Vietinė Žinių Bazė<br/>(Deterministinis Atsarginis)"]
    end

    TRIGGER --> DRAWER
    DRAWER -->|Siųsti Užklausą| C_CHAT
    DRAWER -->|Tikrinti Būsenas| C_STATUS
    DRAWER -->|VS Code Spustelėjimas| C_DEEP
    DRAWER -->|Antigravity Spustelėjimas| C_DEEP
    C_CHAT --> SANITIZER
    SANITIZER --> RAG
    RAG -->|Variklis: Copilot| COPILOT_API
    RAG -->|Variklis: Antigravity| AGY_CLI
    COPILOT_API -.->|Offline / Nėra Žetono| OFFLINE
    AGY_CLI -.->|Nėra CLI| OFFLINE
    C_DEEP --> VSLINK
    C_DEEP --> AGYLINK
```

---

## 🔒 2. Zero-Trust saugumas ir 5 Taisyklės laikymasis

1. **Niekada neišsaugoma diske:** Autentifikavimo žetonai ir komandinės eilutės sąveika vykdomi išimtinai operatyviojoje atmintyje.
2. **Dinaminis maskavimas:** Visi klausimai ir dokumentacijos ištraukos pereina `sanitize_text` filtrą:
   - Duomenų bazių slaptažodžiai (`password: ...`, `IDENTIFIED BY ...`)
   - SEPS Wallet keliai (`cwallet.sso`, `ewallet.p12`)
   - SSH ir TLS privatūs raktai (`BEGIN PRIVATE KEY`)
   - GitHub prieigos žetonai (`ghp_*`, `github_pat_*`)

---

## ⌨️ 3. Kūrėjo spartieji klavišai ir parinktys

| Veiksmas | Spartusis klavišas / Paleidiklis | Aprašymas |
| :--- | :--- | :--- |
| **Atidaryti / Uždaryti asistentą** | `⌘J` (macOS) / `Ctrl+J` (Windows/Linux) | Atidaro arba uždaro AI skydelį iš bet kurios Dev Hub kortelės. |
| **Perjungti variklį** | Antraštės mygtukai `[ GitHub Copilot | Google Antigravity ]` | Perjungia aktyvų AI variklį (`localStorage`). |
| **Visas ekranas / Atstatyti** | Viršutinis dešinysis mygtukas `⛶` | Išplečia skydelį į visą ekraną kodo analizei. |
| **Pateikti klausimą** | `Enter` klavišas | Siunčia užklausą pasirinktam AI varikliui. |
| **Atidaryti „VS Code“** | Spustelėti `Atidaryti „VS Code Copilot“` | Nukopijuoja pilną RAG kontekstą į iškarpinę ir atidaro `vscode://github.copilot/chat`. |
| **Atidaryti su Antigravity** | Spustelėti `Atidaryti su Antigravity` | Nukopijuoja RAG kontekstą į iškarpinę ir atidaro `antigravity://chat` (arba paleidžia programą). |

---

## 🔄 4. 3-Lygmenų atsarginė sistema be interneto

Jei kūrėjo kompiuteryje nėra interneto ryšio:
1. **1 Lygis (Prisijungta):** Kreipiasi į GitHub Models (`gpt-4o`) arba vietinį `agy` CLI.
2. **2 Lygis (CLI atsarga):** Naudoja vietinius CLI įrankius.
3. **3 Lygis (Vietinis be tinklo):** Akimirksniu sugeneruoja deterministinį atsakymą iš vietinės dokumentacijos.
