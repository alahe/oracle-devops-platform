[ 🇬🇧 English ](../../README.md) | [ 🇪🇪 Eesti ](../et/README.md) | [ 🇫🇮 Suomi ](../fi/README.md) | [ 🇸🇪 Svenska ](../sv/README.md) | [ 🇱🇻 Latviešu ](README.md) | [ 🇱🇹 Lietuvių ](../lt/README.md)

# Oracle DevOps Platforma (Latviešu Rokasgrāmata)

> **Ražošanai gatava, bez licences maksas (0 €) un 100% bezparoļu (SEPS Wallet) Oracle 23ai, APEX SSO Vārtejas, Forms 14c, Publisher un Web IDE izstrādes un DevOps platforma.**

---

## ⚡ 60 Sekunžu Ātrā Palaišana

```bash
# 1. Klonēt krātuvi un pāriet uz mapi
git clone https://github.com/allanlahe/oracle-free-db-in-prod.git && cd oracle-free-db-in-prod

# 2. Palaist noklusējuma 2-slāņu ražošanas steku (Blueprint 21)
./scripts/setup-all.sh -b 21 --lang lv

# 3. Skatīt paroles, URL un starpliktuves palīgu (vai atvērt Dev Hub: http://localhost:8088/)
./scripts/get-password.sh
```

---

## 🗺️ Jauna Izstrādātāja Ceļvedis (Onboarding Journey)

```mermaid
flowchart TD
    Start(["🚀 Izstrādātājs Sāk"]) --> Clone["1. git clone & cd oracle-free-db-in-prod"]
    Clone --> ChooseBP{"2. Izvēlēties Arhitektūras Plānu"}
    
    ChooseBP -->|Noklusējuma 2-DB Steks| BP21["./scripts/setup-all.sh -b 21 --lang lv"]
    ChooseBP -->|Forms + Publisher + IDE| BP31["./scripts/setup-all.sh -b 31 --lang lv"]
    ChooseBP -->|Priekšskatījums / Dry-Run| BPDry["./scripts/deploy-blueprint.sh -b 21 --dry-run"]
    
    BP21 --> DevHub["3. Atvērt DevOps Vadības Centru<br/>🌐 http://localhost:8088/"]
    BP31 --> DevHub
    BPDry --> ChooseBP
    
    DevHub --> PwdSpikker["4. Paroļu Špikeris (SEPS Wallet)<br/>./scripts/get-password.sh DB_PROXY_DEV -c"]
    
    PwdSpikker --> DevWork["5. Sākt Izstrādi!"]
    DevWork --> WorkIDE["💻 Web IDE & SQL Developer (:8090)"]
    DevWork --> WorkAPEX["🌟 APEX Builder & SSO Vārteja (:8088)"]
    DevWork --> WorkForms["📐 Forms 14c noVNC Builder (:6082)"]
    DevWork --> WorkPub["📑 Analytics Publisher (:9502)"]
```

---

## ⚡ Setup-All 10-Fāžu Dzīvescikla Arhitektūra

```mermaid
flowchart LR
    P1["1. Attēlu Lejupielāde"] --> P2["2. ORDS Lejupielāde"]
    P2 --> P3["3. APEX Pakotnes"]
    P3 --> P4["4. Konteineru Palaišana"]
    P4 --> P5["5. DB Veselības Gaidīšana"]
    P5 --> P6["6. APEX Uzstādīšana"]
    P6 --> P7["7. Shēmas & SEPS Init"]
    P7 --> P8["8. APEX Lietotņu Izvietošana"]
    P8 --> P9["9. Middleware & Pakalpojumi"]
    P9 --> P10["10. Zelta Momentuzņēmums (~15s DR)"]
```

---

## 🌐 Dev Hub (`http://localhost:8088/`) — Vienots Vadības Centrs (*Single Pane of Glass*)

Izstrādātājiem nav jāatceras desmitiem dažādu portu. **Dev Hub** kalpo kā vienots portāls:
- **1-Klikšķa Pakalpojumu Saites:** Tūlītēja piekļuve APEX Builder, Database Actions (SDW), Forms 14c, HTML5 noVNC Forms Builder un Analytics Publisher.
- **1-Klikšķa Paroļu Kopēšana:** Viens klikšķis nokopē atšifrēto paroli tieši starpliktuvē (gatavs ielīmēšanai ar `Cmd+V` / `Ctrl+V`).
- **Reāllaika Veselības Diagnostika:** Automātiska aiztures pārbaude ik pēc 6 sekundēm.
- **Integrēts Markdown Dokumentācijas Lasītājs:** Lasiet un meklējiet rokasgrāmatas tieši pārlūkprogrammā.
- **Plānu Izvēršana un Pārvaldība:** Izvērsiet un pārslēdziet plānus tīmekļa saskarnē vai ar komandu `./scripts/deploy-blueprint.sh`.

---

## 🔑 Kur Ir Mana Parole? (SEPS Wallet Špikeris)

Visas paroles tiek ģenerētas ar augstu kriptogrāfisko drošību un droši glabātas **Oracle SEPS (Secure External Password Store) Wallet** un Podman Secrets.

```bash
# Skatīt pilnu paroļu un pakalpojumu matricu:
./scripts/get-password.sh

# Kopēt izstrādātāja paroli tieši starpliktuvē:
./scripts/get-password.sh DB_PROXY_DEV -c

# Kopēt APEX administratora paroli:
./scripts/get-password.sh DB_PROXY_APEX_ADMIN -c

# Pievienoties datubāzei ar SQLcl BEZ paroles ievades:
sql /@DB_PROXY_DEV
```

---

## 🎯 3 Ieinteresēto Pušu Skatījumi un Biznesa Vērtība

| Skatījums | Galvenie Ieguvumi un Ikdienas Pieredze | Tehniskais Nodrošinātājs |
| :--- | :--- | :--- |
| **👤 Gala Lietotājs un Bizness** | • **Nav Jāinstalē Programmatūra:** Mūsdienīga HTML5 pārlūka pieredze un APEX Universal Theme.<br/>• **Vienotā Pieteikšanās (SSO):** Viena sesija APEX un Forms sistēmās.<br/>• **Pixel-Perfect Atskaites:** Automatizēta PDF/Excel dokumentu ģenerēšana. | • ORDS Vairāku Baseinu Vārteja<br/>• APEX Reverse Proxy SSO priekš Forms<br/>• Analytics Publisher REST API |
| **💻 Izstrādātājs** | • **~15s FastStart Atkopšana:** Tūlītēja atiestatīšana ar Zelta Momentuzņēmumiem.<br/>• **Bezparoļu SQL:** Tūlītējs savienojums ar `./scripts/sqlcl.sh` un SEPS Wallet.<br/>• **Pārlūka Web IDE:** Pārlūka VS Code ar Oracle SQL Developer un MI asistentiem. | • Podman FastStart Momentuzņēmumi<br/>• SEPS Oracle Wallet Auto-Sinhronizācija<br/>• `code-server` Web IDE Konteiners |
| **🛡️ Audits un Arhitekts** | • **0 € Licences Maksa:** Oracle 23ai Free DB ražošanā.<br/>• **Zero-Trust Tīkla Izolācija:** Datubāze nekad neatver neapstrādātu SQL publiskajam tīklam.<br/>• **Pārvaldīta Izpilde:** EBNF deklaratīvie līgumi, AST drošības analīze un VPD. | • JSON-Relational Duality<br/>• 2-Slāņu Tīkla Topoloģija<br/>• Oracle Virtual Private Database (VPD) |

---

## 🔄 Oracle APEX un Forms 14c Integrācijas Loma

Šajā arhitektūrā **Oracle APEX 26.1** primāri tiek pozicionēts kā:
1. **Forms Modernizācijas Tilts:** Pakāpeniska Forms 14c lietotņu pārnese uz modernām tīmekļa lietotnēm, izmantojot [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/).
2. **Uzņēmuma Līmeņa SSO Reverse Proxy priekš Forms:** APEX nodrošina mūsdienīgu autentifikāciju (Azure Entra ID, SAML, OAuth2) un droši nodod sesiju Forms 14c bez dārgas WebLogic OAM/OIF infrastruktūras.

---

## 📋 11 Kurēti Arhitektūras Plāni (Blueprints)

```mermaid
graph TD
  subgraph Sērija 1-9: Core DB & APEX SSO Vārteja
    BP3["🌟 BP 3 (NOKLUSĒJUMS): 2-Slāņu Ražošanas Steks<br/>db-proxy + db-alise + app-ords (Porti 1532, 1533, 8088)"]
    BP7["BP 7: Vairāku Piegādātāju Hibrīds<br/>Oficiālā Oracle 23ai DB + Gerald Venzl DB + ORDS"]
  end

  subgraph Sērija 10-19: Analytics Publisher
    BP13["BP 13: Viss-Vienā Publisher DB<br/>Viena 23ai DB (RCU + Dati) + Publisher + ORDS"]
    BP11["BP 11: Izolēts Publisher Uzņēmums<br/>3 izolētas DB + Publisher + ORDS"]
  end

  subgraph Sērija 20-29: Oracle Forms 14c & Modernizācija
    BP22["BP 22: Minimāls Forms Hibrīds<br/>Kombinēta Forms/Proxy DB + ALISE DB + Forms 14c + ORDS"]
    BP21["BP 21: Pilns Forms Uzņēmuma Steks<br/>Forms RCU DB + Pielāgota DB + Proxy DB + Forms 14c + ORDS"]
  end

  subgraph Sērija 30-39: Izstrādes Darbstacijas & Web IDE
    BP34["🌟 BP 34: Standarta 2-Slāņu DB + Web IDE<br/>db-proxy + db-alise + app-ords + web-ide-dev (Ports 8090)"]
    BP31["BP 31: Mākoņa Autonomous DB + Web IDE<br/>ADB Emulators + VS Code Web IDE"]
  end

  subgraph Sērija 40-49: Ultimate Enterprise Komplekti
    BP41["🌟 BP 41: Ultimate Viss-Vienā Uzņēmums + Web IDE<br/>Forms + Publisher + APEX SSO + Web IDE uz 1 DB"]
    BP42["BP 42: Pilnībā Izolēta Mākoņa Laboratorija<br/>8 izolēti konteineri, 4 atsevišķas datubāzes"]
    BP43["BP 43: 2-DB Hibrīds Uzņēmums + Web IDE<br/>Proxy DB + Kopīga Middleware RCU DB"]
  end
```

### 🚀 Plānu Izvēršana un Pārvaldība (`./scripts/deploy-blueprint.sh`)

```bash
# 1. Pārbaudīt aktīvo plānu un pakalpojumu veselību:
./scripts/deploy-blueprint.sh --status --lang lv

# 2. Izvērst Blueprint 3 (NOKLUSĒJUMA 2-Slāņu Ražošanas Steks):
./scripts/deploy-blueprint.sh -b 3 --lang lv

# 3. Izvērst Blueprint 41 (Ultimate Viss-Vienā Uzņēmums):
./scripts/deploy-blueprint.sh -b 41 --lang lv

# 4. Simulēt izvēršanu bez izmaiņām (Dry-Run):
./scripts/deploy-blueprint.sh -b 34 --dry-run

# 5. Parādīt 11 plānu tabulu konsolē:
./scripts/deploy-blueprint.sh --list --lang lv
```

---

## ⚡ Paātrināta ~15s Atjaunošana & Automatizēta Versiju Pārbaude

Oracle Free DB in Prod ietver **inteliģentu daudzlīmeņu Golden Snapshot un Skip dzinēju** (`scripts/internal/snapshot-resolver.sh`), kas samazina otro palaišanas laiku no **~6–12 minūtēm līdz ~15 sekundēm**:

1. **Automatizēta Versiju Pārbaude & Novecojušu Momentuzņēmumu Anulēšana (`.meta.json`):**
   - Katrs Golden Snapshot ietver mašīnlasāmu `.meta.json` līgumu, kurā reģistrētas APEX, datubāzes, ORDS un starpprogrammatūras versijas.
   - Pirms atjaunošanas tiek stingri pārbaudīta versiju saderība. Ja tiek atklāts novecojis momentuzņēmums (piem., mērķis `APEX 26.1` pret snapshot `24.2`), sistēma brīdina ar `VERSION MISMATCH`, veic tīru instalēšanu un automātiski ģenerē jaunu atjauninātu momentuzņēmumu.
2. **Profilos Balstīta Atkārtota Izmantošana & Skip Matrica:**
   - Tā kā identiski datubāzes profili tiek koplietoti vairākos plānos (piem., `db-proxy-oracle` BP 3, BP 7, BP 21, BP 22, BP 34, BP 43), pārslēdzot plānus (piem., BP 3 $\rightarrow$ BP 34 Web IDE pievienošanai), datubāze paliek neskarta un tiek palaists tikai trūkstošais konteiners **~3 sekundēs**.
3. **Shared vs. Dedicated WebLogic Topoloģijas:**
   - **Koplietots WebLogic (BP 41 & BP 43):** Viena All-in-One datubāze (`db-dev-full`), vienotas RCU shēmas (`DEV_`), 1 kombinēts momentuzņēmums un zems RAM patēriņš (~6–8 GB).
   - **Specializēts WebLogic (BP 11, BP 21 & BP 42):** Neatkarīgas datubāzes (`db-forms`, `db-publisher`), modulāri momentuzņēmumi un selektīva palaišana, ietaupot līdz 4 GB RAM.

---

## 🚀 Ātrā Palaišana (Quickstart CLI)

```bash
# 1. Palaist izvēlēto blueprint:
./scripts/setup-all.sh -b 3 --lang lv

# 2. Skatīt paroļu un pakalpojumu tabulu (vai kopēt ar -c):
./scripts/get-password.sh
./scripts/get-password.sh DB_PROXY_DEV -c

# 3. Rotēt paroles droši bez dīkstāves:
./scripts/rotate-password.sh db-proxy dev
./scripts/rotate-password.sh all

# 4. Pārbaudīt aktīvos tīmekļa pakalpojumus un SEPS Wallet:
./scripts/check-urls.sh --lang lv
./scripts/check-wallet.sh

# 5. Palaist automatizēto pieteikšanās un saskarnes testu:
./scripts/test-browser-login.sh

# 6. Palaist daudzvalodu (i18n) verifikācijas testu (9. noteikums: EN, ET, FI, SV, LV, LT):
./tests/test-multilingual-support.sh

# 7. Izveidot vai atjaunot Zelta Momentuzņēmumus (~15s atkopšana):
./scripts/snapshots/create-golden-snapshots.sh
./scripts/snapshots/restore-golden-snapshots.sh

# 8. Notīrīt žurnālus, pagaidu failus un vecos momentuzņēmumus:
./scripts/clean-logs.sh -y
./scripts/snapshots/clean-golden-snapshots.sh -y

# 9. Atiestatīt vidi uz tīru sākuma stāvokli:
./scripts/reset-all.sh -y
```

---

## 📑 Lietotāja Rokasgrāmatas

- 🚀 **[docs/lv/forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md):** **Oracle Forms $\rightarrow$ APEX Modernizācijas un Pārejas Rokasgrāmata** — Biznesa pamatojums, TCO salīdzinājums, 5 posmu automatizēta darba plūsma un [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/).
- 📐 **[docs/forms-setup.md](../../docs/forms-setup.md):** Oracle Forms 14c Rokasgrāmata.
- 📑 **[docs/publisher-setup.md](../../docs/publisher-setup.md):** Analytics Publisher Rokasgrāmata.
- 💻 **[docs/web-ide-artifactory.md](../../docs/web-ide-artifactory.md):** Web IDE Rokasgrāmata.
- 🌐 **[docs/dev-hub.html](../../docs/dev-hub.html):** **Developer & DevOps Command Center** (`http://localhost:8088/` un `http://localhost:6082/vnc.html`).
- 📊 **[config/blueprints/README.md](../../config/blueprints/README.md):** 11 Plānu Katalogs.
- 📖 **[Oracle APEX 26.1 APEXlang Reference Manual](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/):** Oficiālā specifikācija deklaratīvajai `.apx` sintaksei un kompilatora komandām.
- 📜 **[Oficiālā APEXlang EBNF Gramatika (`apexlang.ebnf`)](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/apexlang.ebnf):** Mašīnlasāma formālā EBNF specifikācija MI ierobežotai dekodēšanai (GBNF) un statiskajiem drošības skeneriem.

