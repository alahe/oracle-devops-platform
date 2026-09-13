[ 🇬🇧 English ](../devhub-copilot-assistant.md) | [ 🇪🇪 Eesti ](../et/devhub-copilot-assistant.md) | [ 🇫🇮 Suomi ](devhub-copilot-assistant.md) | [ 🇸🇪 Svenska ](../sv/devhub-copilot-assistant.md) | [ 🇱🇻 Latviešu ](../lv/devhub-copilot-assistant.md) | [ 🇱🇹 Lietuvių ](../lt/devhub-copilot-assistant.md)

# 🤖 Dev Hub Monialustainen AI-avustaja (Copilot + Antigravity) ja Zero-Trust RAG -opas

Tämä opas dokumentoi Developer Hubin (`docs/dev-hub.html`) monialustaisen **AI-avustajan**, joka tukee sekä **GitHub Copilotia** että **Google Antigravitya**, Sääntö 5 Zero-Trust -tietoturvakontrolleja, offline-tietokantaa sekä 1-klikauksen siltoja VS Code Copilot Chatiin ja Antigravityyn.

---

## 🏛️ 1. Tekninen arkkitehtuuri ja tietovirta

Avustaja hyödyntää kahden moottorin arkkitehtuuria pikanäppäimellä `⌘J` / `Ctrl+J`, mahdollistaen nopean vaihdon GitHub Copilotin ja Google Antigravityn välillä:

```mermaid
flowchart TD
    subgraph UI ["🖥️ Developer Hub Käyttöliittymä (dev-hub.html)"]
        TRIGGER["Kelluva Toimintopainike<br/>tai Pikanäppäin ⌘J / Ctrl+J"]
        DRAWER["AI Sivupaneeli<br/>(Moottorikytkin & Keskustelu)"]
        VSLINK["1-Klikkauksen VS Code Painike<br/>(Syvälinkki & Leikepöytä)"]
        AGYLINK["1-Klikkauksen Antigravity Painike<br/>(antigravity:// & Leikepöytä)"]
    end

    subgraph Bridge ["⚡ Paikallinen Silta (dev-hub-bridge.py :8089)"]
        C_STATUS["GET /api/ai/status<br/>(Copilot & Antigravity Tarkistus)"]
        C_CHAT["POST /api/ai/chat<br/>(Älykäs RAG & Puhdistus)"]
        C_DEEP["POST /api/ai/deeplink<br/>(Luo URI & Kontekstin)"]
    end

    subgraph Security ["🔒 Zero-Trust Moottori (copilot.py)"]
        SANITIZER["Regex Salaisuuksien Piilotus<br/>(Salasanat, Avaimet, Walletit)"]
        RAG["Älykäs RAG Poimija<br/>(Blueprint, Dokumentit, 1500 Tokenia)"]
    end

    subgraph Providers ["⚙️ Suoritusmoottorit"]
        COPILOT_API["GitHub Models / Copilot API<br/>(gpt-4o muistipohjaisella tokenilla)"]
        AGY_CLI["Google Antigravity Moottori<br/>(Paikallinen agy CLI -suoritus)"]
        OFFLINE["Paikallinen Tietokanta<br/>(Deterministinen Vara)"]
    end

    TRIGGER --> DRAWER
    DRAWER -->|Lähetä Kysely| C_CHAT
    DRAWER -->|Tarkista Olekut| C_STATUS
    DRAWER -->|VS Code Klikkaus| C_DEEP
    DRAWER -->|Antigravity Klikkaus| C_DEEP
    C_CHAT --> SANITIZER
    SANITIZER --> RAG
    RAG -->|Moottori: Copilot| COPILOT_API
    RAG -->|Moottori: Antigravity| AGY_CLI
    COPILOT_API -.->|Offline / Ei Tokenia| OFFLINE
    AGY_CLI -.->|CLI Puuttuu| OFFLINE
    C_DEEP --> VSLINK
    C_DEEP --> AGYLINK
```

---

## 🔒 2. Zero-Trust -tietoturva ja Sääntö 5 noudattaminen

1. **Ei tallennusta levylle:** Tunnistetiedot ja komentorivin vuorovaikutus hoidetaan muistipohjaisesti.
2. **Dynaaminen sensurointi:** Kaikki käyttäjän kyselyt ja dokumentaatiolainaukset kulkevat `sanitize_text`-funktion läpi:
   - Tietokantojen salasanat (`password: ...`, `IDENTIFIED BY ...`)
   - SEPS Wallet -polut (`cwallet.sso`, `ewallet.p12`)
   - SSH- ja TLS-yksityisavaimet (`BEGIN PRIVATE KEY`)
   - GitHub-käyttöoikeustunnisteet (`ghp_*`, `github_pat_*`)

---

## ⌨️ 3. Kehittäjän pikanäppäimet ja toiminnot

| Toiminto | Pikanäppäin / Käynnistin | Kuvaus |
| :--- | :--- | :--- |
| **Avaa / Sulje Avustaja** | `⌘J` (macOS) / `Ctrl+J` (Windows/Linux) | Avaa tai sulkee AI-paneelin miltä tahansa Dev Hubin välilehdeltä. |
| **Moottorin vaihto** | Otsikon painikkeet `[ GitHub Copilot | Google Antigravity ]` | Vaihtaa aktiivisen tekoälymoottorin (`localStorage`). |
| **Koko näyttö / Palauta** | Oikean yläkulman painike `⛶` | Laajentaa paneelin koko ruudun tilaan koodin tarkastelua varten. |
| **Kysymyksen lähetys** | `Enter`-näppäin | Lähettää kyselyn valitulle tekoälymoottorille. |
| **Avaa VS Codessa** | Napsauta `Avaa VS Code Copilotissa` | Kopioi täyden RAG-kontekstin leikepöydälle ja avaa `vscode://github.copilot/chat`. |
| **Avaa Antigravityssä** | Napsauta `Avaa Antigravityssä` | Kopioi RAG-kontekstin leikepöydälle ja avaa `antigravity://chat` (tai käynnistää sovelluksen). |

---

## 🔄 4. 3-Tasoinen offline-varajärjestelmä

Jos kehityskoneessa ei ole verkkoyhteyttä:
1. **Taso 1 (Yhdistetty):** Käyttää GitHub Models (`gpt-4o`) -rajapintaa tai paikallista `agy` CLI -komentoa.
2. **Taso 2 (CLI-vara):** Käyttää paikallisia CLI-työkaluja.
3. **Taso 3 (Offline):** Luo välittömän deterministisen vastauksen paikallisesta dokumentaatiosta.
