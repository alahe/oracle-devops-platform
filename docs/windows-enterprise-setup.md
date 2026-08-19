# 🏢 Windows Enterprise Podman Liivakasti Juhend (Zero Trust)

See juhend kirjeldab, kuidas käivitada **konteineriseeritud Web IDE (`code-server`) keskkonda Windows Enterprise sülearvutites**, mille puhul ettevõtte turvareeglid ei luba lokaalsesse Windows operatsioonisüsteemi tarkvara ega utiliite paigaldada.

---

## 🔒 Miks see lahendus vastab ettevõtte turvanõuetele (Firm Rules)?

1. **Host OS (Windows) jääb 100% puhtaks:**
   * Ühtegi koodiredaktorit, Pythoni, Javat ega Git-i **ei paigaldata Windowsi operatsioonisüsteemi**.
   * Kogu keskkond jookseb isoleeritud **Podman konteineris**.
2. **Liides brauseris (Edge / Chrome Enterprise):**
   * Arenduskeskkond avaneb turvaliselt brauseris aadressil **`http://localhost:8090`**.
   * Windows ei vaja graafikaedastuse teenuseid ega lisatarkvara.
3. **Ettevõtte Artifactory peegeldusregister (Rule 4):**
   * Kui ettevõte blokeerib avaliku interneti hoidlad, saab `.env` failis määrata sisevõrgu peegeldusregistri:
     ```bash
     ARTIFACTORY_DOCKER_REGISTRY=artifactory.corp.internal
     ```

---

## 🚀 Käivitamine Windows Masinas

Ava PowerShell projekti kaustas ja käivita konteinerid:
```powershell
podman-compose -f podman-compose.yml --profile web-ide up -d
```

---

## 🖥️ Kasutamine brauseris

1. Ava oma arvuti brauseris aadress:
   **`http://localhost:8090`**
2. Brauseris ootab täielik brauseripõhine VS Code, mille sees on:
   * **Oracle SQLcl** (paroolivaba SEPS Wallet ühendus)
   * **Git ja terminali tööriistad**
   * **VS Code laienduste tugi (.vsix)**

---

## 🛑 Puhastamine ja peatamine

Konteineri sulgemiseks ja mälu vabastamiseks:
```powershell
podman-compose down
```
