# 🏢 Windows Enterprise Podman Liivakasti Juhend (Zero Trust)

See juhend kirjeldab, kuidas käivitada **Google Antigravity tehisintellekti ja Web IDE keskkonda Windows Enterprise sülearvutites**, mille puhul ettevõtte turvareeglid ei luba lokaalsesse Windows operatsioonisüsteemi tarkvara ega utiliite paigaldada.

---

## 🔒 Miks see lahendus vastab ettevõtte turvanõuetele (Firm Rules)?

1. **Host OS (Windows) jääb 100% puhtaks:**
   * Ühtegi koodiredaktorit, Pythoni, Javat, Git-i ega AI agenti **ei paigaldata Windowsi operatsioonisüsteemi**.
   * Kogu keskkond jookseb isoleeritud **Podman konteineris**.
2. **Liides brauseris (Edge / Chrome / Chrome Enterprise):**
   * Arenduskeskkond avaneb turvaliselt brauseris aadressil **`http://localhost:8090`**.
   * Windows ei vaja X11, XQuartz ega mingeid keerulisi graafikaedastuse dreenusid.
3. **Ettevõtte Artifactory peegeldusregister (Rule 4):**
   * Kui ettevõte blokeerib avaliku interneti hoidlad, saab `.env` failis määrata sisevõrgu peegeldusregistri:
     ```bash
     ARTIFACTORY_DOCKER_REGISTRY=artifactory.corp.internal
     ```

---

## 🚀 Käivitamine Windows Masinas (1-Klikiga)

### Variant 1: Hiireklõpsuga (.bat fail)
Tee oma Windows sülearvutis kaustas `scripts/` dubleeritud klõps failil:
👉 **`scripts/run-antigravity-windows.bat`**

### Variant 2: Windows PowerShellist
Ava PowerShell projekti kaustas ja käivita:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-antigravity-windows.ps1
```

---

## 🖥️ Kasutamine brauseris

1. Pärast skripti käivitamist avaneb brauseris automaatselt aadress:
   **`http://localhost:8090`**
2. Brauseris ootab täielik brauseripõhine VS Code, mille sees on:
   * **Google Antigravity / Gemini AI Chat**
   * **Oracle SQLcl** (paroolivaba SEPS Wallet ühendus)
   * **Git ja terminali tööriistad**

---

## 🛑 Puhastamine ja peatamine

Konteineri ja kõigi taustaprotsesside täielikuks sulgemiseks ja vabastamiseks:
```powershell
podman-compose down
```
