[ 🇬🇧 English ](../devhub-copilot-assistant.md) | [ 🇪🇪 Eesti ](devhub-copilot-assistant.md) | [ 🇫🇮 Suomi ](../fi/devhub-copilot-assistant.md) | [ 🇸🇪 Svenska ](../sv/devhub-copilot-assistant.md) | [ 🇱🇻 Latviešu ](../lv/devhub-copilot-assistant.md) | [ 🇱🇹 Lietuvių ](../lt/devhub-copilot-assistant.md)

# 🤖 Dev Hub mitmik-mootoriga AI assistent (Copilot + Antigravity) ja Zero-Trust RAG juhend

Käesolev juhend dokumenteerib Developer Hubi (`docs/dev-hub.html`) integreeritud **mitmik-mootoriga AI assistendi**, mis toetab nii **GitHub Copilotit** kui ka **Google Antigravityt**, selle Reegel 5 Zero-Trust turvakontrolle, võrguühenduseta (offline) lokaalset teadmusbaasi ning 1-klikiga eksporti nii VS Code Copilot Chati kui ka Antigravity töölauarakendusse.

---

## 🏛️ 1. Tehniline arhitektuur ja andmevoog

Assistent kasutab hübriidset mitmik-mootori arhitektuuri: kättesaadav igalt Dev Hubi vahekaardilt kiirklahviga `⌘J` / `Ctrl+J`, võimaldades mugavat teenusepakkuja vahetust GitHub Copiloti ja Google Antigravity vahel:

```mermaid
flowchart TD
    subgraph UI ["🖥️ Developer Hubi Kasutajaliides (dev-hub.html)"]
        TRIGGER["Ujuv Tegevusnupp<br/>või Kiirklahv ⌘J / Ctrl+J"]
        DRAWER["AI Külgsahtel<br/>(Mootorilüliti & Vestlus)"]
        VSLINK["1-Kliki VS Code Nupp<br/>(Süvalink & Lõikelaud)"]
        AGYLINK["1-Kliki Antigravity Nupp<br/>(antigravity:// & Lõikelaud)"]
    end

    subgraph Bridge ["⚡ Lokaalne Sild (dev-hub-bridge.py :8089)"]
        C_STATUS["GET /api/ai/status<br/>(Copiloti & Antigravity Kontroll)"]
        C_CHAT["POST /api/ai/chat<br/>(Nutikas RAG & Puhastus)"]
        C_DEEP["POST /api/ai/deeplink<br/>(Koostab URI & Konteksti)"]
    end

    subgraph Security ["🔒 Zero-Trust Mootor (copilot.py)"]
        SANITIZER["Regex Saladuste Peitmine<br/>(Paroolid, Võtmed, Walletid)"]
        RAG["Nutikas RAG Väljavõtja<br/>(Blueprint, Dokumendid, 1500 Tokenit)"]
    end

    subgraph Providers ["⚙️ Mitmik-Mootorite Käivituskeskkonnad"]
        COPILOT_API["GitHub Models / Copilot API<br/>(gpt-4o mälupõhise tokeniga)"]
        AGY_CLI["Google Antigravity Mootor<br/>(Kohalik agy CLI käivitus)"]
        OFFLINE["Lokaalne Teadmusbaas<br/>(Deterministlik Tagavara)"]
    end

    TRIGGER --> DRAWER
    DRAWER -->|Saada Päring| C_CHAT
    DRAWER -->|Kontrolli Olekuid| C_STATUS
    DRAWER -->|VS Code Klõps| C_DEEP
    DRAWER -->|Antigravity Klõps| C_DEEP
    C_CHAT --> SANITIZER
    SANITIZER --> RAG
    RAG -->|Mootor: Copilot| COPILOT_API
    RAG -->|Mootor: Antigravity| AGY_CLI
    COPILOT_API -.->|Offline / Token Puudub| OFFLINE
    AGY_CLI -.->|CLI Puudub| OFFLINE
    C_DEEP --> VSLINK
    C_DEEP --> AGYLINK
```

---

## 🔒 2. Zero-Trust turvalisus ja Reegel 5 täitmine

Et tagada ettevõtte rangetele turvanõuetele vastavus:
1. **Ei salvestata kettale:** Autentimistokenid ja käsurea interaktsioonid toimuvad mälupõhiselt ilma kettale salvestamata.
2. **Dünaamiline redigeerimine:** Kõik kasutaja päringud ja platvormi dokumentatsiooni väljavõtted läbivad funktsiooni `sanitize_text`:
   - Andmebaasi paroolid (`password: ...`, `IDENTIFIED BY ...`)
   - SEPS Walleti asukohad (`cwallet.sso`, `ewallet.p12`)
   - SSH ja TLS privaatvõtmed (`BEGIN PRIVATE KEY`)
   - GitHubi isiklikud pääsuload (`ghp_*`, `github_pat_*`)

---

## ⌨️ 3. Arendaja kiirklahvid ja võimalused

| Toiming | Kiirklahv / Käivitaja | Kirjeldus |
| :--- | :--- | :--- |
| **Ava / Sule Assistent** | `⌘J` (macOS) / `Ctrl+J` (Windows/Linux) | Avab või sulgeb AI sahtli mistahes Dev Hubi vahekaardilt. |
| **Mootori vahetamine** | Päise nupud `[ GitHub Copilot | Google Antigravity ]` | Lülitab aktiivse mootori (valik salvestub `localStorage`'is). |
| **Täisekraan / Taasta** | Ülal paremal nupp `⛶` | Laiendab sahtli täisekraanile koodi mugavamaks vaatlemiseks. |
| **Küsimuse saatmine** | `Enter` klahv | Edastab päringu valitud AI mootorile. |
| **Ava VS Code'is** | Klõps nupul `Ava VS Code Copilotis` | Kopeerib täieliku RAG konteksti lõikelauale ja avab `vscode://github.copilot/chat`. |
| **Ava Antigravitys** | Klõps nupul `Ava Antigravitys` | Kopeerib täieliku RAG konteksti lõikelauale ja avab `antigravity://chat` (või käivitab töölauarakenduse). |

---

## 🔄 4. 3-Tasemeline võrguühenduseta tagavarasüsteem

Kui arendaja arvutil puudub internetiühendus:
1. **Tase 1 (Ühendatud):** Pöördub GitHub Models (`gpt-4o`) poole või käivitab kohaliku `agy` CLI.
2. **Tase 2 (CLI Tagavara):** Kasutab lokaalseid CLI abivahendeid.
3. **Tase 3 (Lokaalne Offline):** Genereerib kohese deterministliku vastuse repo dokumentatsiooni põhjal.
