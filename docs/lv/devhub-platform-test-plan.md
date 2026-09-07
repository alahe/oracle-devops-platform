# 🧪 Dev Hub & Platformas Modernizācijas Testēšanas Plāns

[ 🇬🇧 English ](../devhub-platform-test-plan.md) | [ 🇪🇪 Eesti ](../et/devhub-platform-test-plan.md) | [ 🇫🇮 Suomi ](../fi/devhub-platform-test-plan.md) | [ 🇸🇪 Svenska ](../sv/devhub-platform-test-plan.md) | [ 🇱🇻 Latviešu ](devhub-platform-test-plan.md) | [ 🇱🇹 Lietuvių ](../lt/devhub-platform-test-plan.md)

---

## 1. Pārskats un Mērķi

Šis testēšanas plāns nosaka Developer Hub (`docs/dev-hub.html`) un platformas orķestrēšanas uzlabojumu pārbaudes stratēģiju un standartizētos testa gadījumus.

### Galvenie Testēšanas Mērķi:
1. **Precīza un Autonoma Statusa Noteikšana:** Nodrošināt, ka Dev Hub precīzi identificē aktīvos blueprintus (ieskaitot vairāku blueprintu vienlaicīgu darbību) un nekad kļūdaini neuzrāda apturētas vides (piemēram, BP #3 un BP #4) kā aktīvas.
2. **Resursu Monitora Uzticamība:** Pārbaudīt, ka galvenes RAM mērītājs (`X GB / 16 GB`) summē tikai faktiski strādājošo konteineru atmiņas limitus.
3. **3-Ciļņu Modālā Dialoga Funkcionalitāte:** Apstiprināt vienmērīgu pārslēgšanos starp cilnēm (`Arhitektūra`, `Lietotāji un Drošība`, `Izpilde un Pārvaldība`), interaktīvas Mermaid topoloģijas diagrammas, SEPS Wallet akreditācijas datus un reāllaika izpildes taimeri.
4. **Database Actions & APEX Launchpad:** Pārbaudīt 5 galapunktu pogas, JVM/ORDS uzsilšanas paziņojumu (*warmup toast*) un automātisku paroles kopēšanu starpliktuvē.
5. **Zero-Trust Drošība & SEPS Wallet:** Pierādīt, ka paroles tiek lasītas tikai atmiņā no šifrētā maka un nekad netiek saglabātas vienkāršā tekstā DOM vai diska kešatmiņā.
6. **Pārvaldnieki un Filtri:** Pārbaudīt profilu un blueprintu sarakstus, klonēšanu, rediģēšanu un filtru (`Aktīvie`, `Remote` utt.) darbību.
7. **Daudzvalodība (i18n):** Garantēt 100% paritāti visās 6 atbalstītajās valodās (🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT).

---

## 2. Testēšanas Piramīda un Pārklājuma Matrica

| Līmenis | Joma | Rīki | Ilgums | Biežums |
| :--- | :--- | :--- | :--- | :--- |
| **1. līmenis** | Kods un Kompilācija | Python 3, `test-dev-hub-generation.sh` | ~5–10s | Katra koda izmaiņa |
| **2. līmenis** | Integrācija un Wallet | `check-urls.sh`, `check-wallet.sh` | ~10–20s | Pēc konteineru palaišanas |
| **3. līmenis** | UI / Funkcionalitāte | Tīmekļa pārlūks, DevTools, Clipboard API | ~3–5 min | Pirms laidiena |
| **4. līmenis** | Dzīvescikls un Atjaunošana | `setup-all.sh`, `restore-golden-snapshots.sh` | ~15–45s | Blueprintu maiņas laikā |

---

## 3. Detalizēti Testa Gadījumi

### A grupa: Statusa Noteikšana un Resursu Uzraudzība

- **TC-STATUS-01: Viena Blueprinta Noteikšana (BP #0)**
  - *Priekšnosacījums:* Palaists `./scripts/setup-all.sh --blueprint 0`.
  - *Sagaidāmais rezultāts:* BP #0 ir zaļš `Aktīvs`. BP #1, #2, #3, #4, #5 ir pelēki `Apturēts`. Galvenē redzams `(1 aktīvs)` un RAM atbilst BP 0 limitam (~3.0 GB).
- **TC-STATUS-02: BP #3 un BP #4 Izolācija**
  - *Priekšnosacījums:* BP #1 darbojas (`db-alise` un `app-ords` ir palaisti).
  - *Sagaidāmais rezultāts:* BP #1 ir `Aktīvs` (`db-alise`). BP #3 (`db-gvenzl`) un BP #4 (`db-adb`) ir `Apturēts`. BP 3/4 RAM netiek pieskaitīts mērītājam.
- **TC-STATUS-03: Vairāku Blueprintu Vienlaicīga Darbība**
  - *Priekšnosacījums:* BP #0 un BP #8 darbojas vienlaicīgi.
  - *Sagaidāmais rezultāts:* Abi ir zaļi `Aktīvs`. Galvenē redzams `(2 aktīvi)` un RAM tiek aprēķināts kā abu summa. Aktīvās kartītes tiek kārtotas saraksta sākumā.

### B grupa: 3-Ciļņu Modālais Dialogs & Dzīvescikla Kontrolieris

- **TC-MODAL-01: Ciļņu Navigācija**
  - *Darbības:* Noklikšķiniet uz kartītes `📐 Arhitektūra ↗` vai `⚡ Pārvaldība ↗`. Pārslēdzieties starp `📐 Arhitektūra`, `🔑 Lietotāji`, `⚡ Izpilde un Pārvaldība`.
  - *Sagaidāmais rezultāts:* Tūlītēja ciļņu maiņa bez lapas pārlādes; nolaižamā izvēlne ļauj pārslēgt blueprintu.
- **TC-MODAL-02: Mermaid Topoloģija un Arhitektūra**
  - *Sagaidāmais rezultāts:* Mermaid SVG tiek renderēts nevainojami, tehniskie porti un konteineru tabula ir precīza.
- **TC-MODAL-03: Izpilde un Pārvaldība (Vienotais Darbību Režģis & Reāllaika Konsole)**
  - *Darbības:* Cilnē "Izpilde un Pārvaldība" pārbaudiet vienoto darbību kartīšu režģi (Izvietot & Pārslēgt, Ātrā atkopšana no Zelta kopijas, Restartēt, Dziļā tīrīšana, Apturēt pakalpojumus, Saglabāt stāvokli). Noklikšķiniet uz jebkuras darbības pogas (piemēram, `⚡ Aktivizēt` vai `⚡ Atjaunot Zelta Kopiju`).
  - *Sagaidāmais rezultāts:* Katrā kartītē ir skaidrojums, kopējams čaulas komandas lauks un poga. Reāllaika progresa konsole (`modal-ops-console`) atveras tieši zem kartītēm un automātiski ritinās skatā ar reāllaika taimeri (`⏱️ 00:01`...). Liekais komandu bloks loga apakšā ir noņemts.

### C grupa: Pakalpojumu Kartītes un Database Actions Launchpad

- **TC-LAUNCH-01: 5 Galapunktu Pogu Pārbaude**
  - *Sagaidāmais rezultāts:* Datubāzu kartītēs ir 5 pogas: `🛠️ APEX Workspace (DEV)`, `⚙️ APEX Admin (ADMIN)`, `📊 DB Actions (DEV)`, `📊 DB Actions (DBA_ADMIN)`, `🌐 ORDS (<pool>)`.
- **TC-LAUNCH-02: DB Actions Uzsilšanas Paziņojums & Parole**
  - *Darbības:* Noklikšķiniet uz `📊 DB Actions (DEV)`.
  - *Sagaidāmais rezultāts:* Parādās paziņojums par ielādes laiku (~10–15s), parole tiek nokopēta starpliktuvē, atveras pareizais URL.
- **TC-LAUNCH-03: APEX Workspace Paroles Kopēšana**
  - *Darbības:* Noklikšķiniet uz `🛠️ APEX Workspace (DEV)`.
  - *Sagaidāmais rezultāts:* Izstrādātāja parole tiek nokopēta starpliktuvē un atveras APEX pieteikšanās lapa.

### D grupa: Oracle SEPS Wallet Credential Matrix

- **TC-WALLET-01: Dinamiska Kontu Apvienošana**
  - *Sagaidāmais rezultāts:* Visi YAML profilu konti ir redzami tabulā pie attiecīgajām datubāzēm un portiem.
- **TC-WALLET-02: Darbību Pogas Tabulā**
  - *Sagaidāmais rezultāts:* Pogas `[ 🔑 Parole ]`, `[ 📋 Alias ]`, `[ 💻 SQLcl ]`, `[ 📊 DB Actions ]` veic darbību un parāda apstiprinājumu.
- **TC-WALLET-03: Zero-Trust Drošības Pārbaude**
  - *Sagaidāmais rezultāts:* Paroles nav redzamas HTML avota kodā; tās tiek nolasītas reāllaikā no maka atmiņā.

### E grupa: Pārvaldnieki un Filtri

- **TC-MGR-01: Profilu Pārvaldnieks**
  - *Sagaidāmais rezultāts:* Kreisajā pusē saraksts, labajā YAML saturs, klonēšanas un rediģēšanas funkcija.
- **TC-MGR-02: Blueprintu Pārvaldnieks**
  - *Sagaidāmais rezultāts:* Kreisajā pusē saraksts, labajā konfigurācija, pievienošanas forma darbojas.
- **TC-MGR-03: Kartīšu Režģis un Filtri**
  - *Sagaidāmais rezultāts:* Filtri (`Aktīvie`, `Remote` utt.) darbojas bez kavēšanās, 3 kolonnu izkārtojums darbojas.

### F grupa: Daudzvalodība (i18n)

- **TC-I18N-01: 6 Valodu Dinamiskā Pārslēgšana**
  - *Sagaidāmais rezultāts:* Karodziņu pogas pārslēdz saskarnes valodu nevainojami (EN, ET, FI, SV, LV, LT).

---

## 4. Automatizētās Testēšanas Komandas

```bash
# 1. Dev Hub kompilācija un 6 valodu vienībtesti
bash tests/unit/test-dev-hub-generation.sh

# 2. SEPS Wallet un savienojumu diagnostika
./scripts/check-wallet.sh

# 3. Pakalpojumu galapunktu diagnostika
./scripts/check-urls.sh

# 4. Blueprint CLI parametru pārbaude
bash tests/unit/test-cli-blueprint-params.sh

# 5. Golden Snapshot ātrās atjaunošanas regresijas tests
bash tests/unit/test-script-restore-golden-snapshots.sh
```
