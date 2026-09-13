# DevOps Juhtpaneeli Tootespetsifikatsioon (Product Specification)

- **Dokumendi versioon:** 1.0.0
- **Staatus:** Ametlik tootespetsifikatsioon
- **Sihtrühm:** APEX arendajad, Oracle DBA-d, DevOps insenerid, AI agendid

---

## 1. Eesmärk ja Ärivajadus

DevOps juhtpaneel on **Oracle DevOps Platformi** keskne operatsiooniline tööriist, mis võimaldab arendajatel ja administraatoritel hallata konteinerite, andmebaaside, SEPS Walleti, sertifikaatide ja hetktõmmiste elutsüklit ilma käsitsi CLI süntaksit pähe õppimata.

### Kasutajarollid:
1. **APEX / Andmebaasi Arendaja:** Vajab kiiret, 1-klõpsuga lokaalset keskkonda (FastStart ~15s), kasutajate lisamist (`create-developer.sh`) ja kiiret ligipääsu SQLcl terminalile.
2. **DevOps / Süsteemiadministraator:** Vajab süsteemi sügavlähtestust (`reset-all.sh --system`), sertifikaatide genereerimist ja CI/CD ettevalmistust.
3. **AI Paarisprogrammeerija (Copilot / Antigravity):** Suhtleb juhtpaneeli sillaga (`dev-hub-bridge.py`), diagnoosib logisid ja aitab tõrkeid parandada.

---

## 2. Funktsionaalsed Nõuded

### REQ-1: Eraldatus Testimisest (Single Responsibility)
- Vahekaart `⚡ DevOps` sisaldab eranditult **platvormi halduse, elutsükli ja diagnostika käske**.
- Kõik CI testid, automaattestide käivitajad ja testiraportid asuvad eranditult vahekaardil `🧪 Testimine`.

### REQ-2: 3-Tasemeline Adaptiivne Logiliides
- **Tase 1 (Kaardil):** Ainult reaalajas stopper (`⏱️ 0:14...`), tegevuse olek ja tulemus (`EXIT 0` / `EXIT 1`). Kaardi kõrgus on staatiline.
- **Tase 2 (Dokitav Terminal):** Allosast väljalibisev konsool, mille kõrgust saab reguleerida vahemikus 300–600px. Logivoog ei tohi katkeda lehe vahetamisel.
- **Tase 3 (Täisekraan):** Täisekraani režiim (`⛶`) koos `Ctrl+F` otsinguga otse logist, ANSI värvide esiletõstuga ja logi kopeerimise nupuga.

### REQ-3: Reeglipõhised Command Studiod
- **Setup Studio:**
  - Valikurežiimid: `Täispaigaldus (-y)`, `FastStart (-s -y)`, `Puhas algus (--fresh)`, `Simulatsioon (--dry-run)`.
  - Smart Disabling: FastStart välistab valiku `--fresh` ja vastupidi.
  - Reaalajas käsurea generaator ja inimkeelne toime kokkuvõte.
- **Reset Studio:**
  - Režiimid: `Standardne lähtestus`, `Täielik süsteemipuhastus (--system)`.
  - Lisalipud: `--clean-logs`, `--clean-certs`.

### REQ-4: Operatsiooniline Ohutus ja Kinnituskaitse
- Hävitavad toimingud (`reset-all --system`, `clean-snapshots`) on visuaalselt tähistatud punase/merevaigu hoiatusäärisega.
- Käivitusnupp nõuab 2-astmelist kinnitust (*"Oled kindel?"*) enne käsu teostamist.

### REQ-5: AI Assistentide Sünergia (Copilot & Antigravity)
- Ebaõnnestunud käsu korral kuvatakse terminalis nupp `🤖 Küsi AI-lt lahendust`.
- Nupule vajutamisel avaneb Copiloti/Antigravity aken koos täpse veateate ja taastamisjuhise päringuga.

---

## 3. Mittefunktsionaalsed ja Turvanõuded

1. **Shell Injection Kaitse:** Kõik parameetrid valideeritakse regexiga `^[a-zA-Z0-9_]{3,30}$`. Pythonis kasutatakse `subprocess.Popen([args...])` ilma `shell=True`.
2. **Protsesside Lukustus (Mutex Lock):** Samaaegsed pikaajalised toimingud on blokeeritud (`409 Conflict`).
3. **Mälukaitse (Ring-Buffer):** Brauseris hoitakse mälus max 1500 rida logi. Täislogi asub lokaalsel kettal kaustas `install_logs/`.
4. **Kohalikkus ja Git-kaitse:** Kaust `install_logs/` on range lokaalne invariant ja ei jõua kunagi Giti repositooriumisse.
