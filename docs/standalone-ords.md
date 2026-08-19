# 🏢 Eraldiseisva Standalone ORDS Serveri Paigaldus ja Testimine Ettevõttes

See juhend kirjeldab **Oracle REST Data Services (ORDS)** eraldiseisva (Standalone) teenuse paigaldamist, konfigureerimist ja testimist ettevõtte infrastruktuuris või eraldi Linux virtuaalmasinas/serveris.

---

## 🏗️ 2 Ettevõtte Testimata / Katsestsenaariumi

### 🔹 Stsenaarium A: Ettevõttes on juba olemas eraldiseisev ORDS server

Kui ettevõtte infrastruktuuris on ORDS teenus juba eraldi serveris seadistatud ning soovid lokaalselt või serveris paigaldada AINULT andmebaasi ja APEX mootori:

Käivita paigaldus ilma lokaalse ORDS konteinerita:
```bash
./scripts/setup-all.sh --no-ords
```
* **Mis juhtub?** Paigaldatakse Oracle DB, luuakse kasutajad/skeemid ja installeeritakse APEX mootor, kuid **lokaalset ORDS konteinerit ei käivitata**.
* **Ühendamine:** Välise ORDS serveri ühenduse andmed seadistatakse failis `.env` (`APEX_DB_HOST`, `APEX_DB_PORT`).

---

### 🔹 Stsenaarium B: Uue eraldiseisva Standalone ORDS serveri paigaldamine

Kui soovid ise paigaldada ja testida eraldiseisvat ORDS serverit eraldi Linux virtuaalmasinas (RedHat / Oracle Linux / Ubuntu):

#### 1. Eeldused (Prerequisites):
*   **Java:** Serverisse peab olema paigaldatud Java 11, 17 või 21.
*   **Võrguühendus:** Serverist peab olema pääs andmebaasile (standard port 1521/1522 või turvaline TCPS port 2484).
*   **Tarkvara hoidla:** Allalaadimise URL-id (nt sise-Artifactory või OTN) on seadistatavad failis `config/repository.env`.

#### 2. Automaatne paigaldamine (`install-ords-standalone.sh`):

Käivita paigaldusskript eraldiseisvas Linux serveris:
```bash
# Määratle sihtandmebaasi rekvisiidid:
DB_HOST="192.168.1.100" \
DB_PORT=1521 \
DB_SERVICE="FREEPDB1" \
./scripts/internal/install-ords-standalone.sh
```

#### 3. Skripti teostatavad sammud:
1. **Java kontroll:** Kontrollib, kas süsteemis on Java 17/21 olemas.
2. **Tarkvara allalaadimine:** Tõmbab ORDS `.zip` faili konfigureeritud Artifactory või OTN aadressilt.
3. **Paigaldamine:** Pakib ORDS-i lahti asukohta `/opt/ords` ja loodab vajaliku kataloogistruktuuri.
4. **APEX staatilised pildid:** Kopeerib APEXi pildifailid kausta `/opt/ords/apex/images`.
5. **Seadistus (`/etc/ords/config`):** Loob ühenduse konfiguratsiooni sihtandmebaasiga (`pool.xml`) ning teostab vajadusel `ORDS_METADATA` skeemi paigalduse.
6. **Linux Systemd Teenus:** Registreerib ORDS-i Linuxi systemd teenusena (`ords.service`), mis tagab automaatse käivitumise serveri taaskäivitusel.

#### 4. Lokaalne Emuleerimine ilma eraldi serverita (`test-standalone-ords-emulation.sh`):

Kui sul ei ole praegu eraldi Linux serverit, kuid soovid Standalone ORDS-i paigaldust reaalajas testida, käivita emuleerimise skript:
```bash
./scripts/test-standalone-ords-emulation.sh
```
* **Mis juhtub?** Skript käivitab isoleeritud Linux konteineri (`ords-standalone-emulator`), paigaldab sinna Java 17 ja ORDS-i ning ühendab selle lokaalse `db-apex-proxy` andmebaasiga samamoodi nagu päris eraldiseisev server.

---

## 🛠️ Konfigureerimine ja Haldus Käsurealt

Kõik ORDS-i konfiguratsiooniväärtused loetakse ja salvestatakse ORDS-i seadete kausta (vaikimisi `/etc/ords/config`). Seadeid saab muuta käsurealt:

```bash
# Kontrolli ORDS-i aktiivset konfiguratsiooni:
ords --config /etc/ords/config config list

# Muuda Gateway režiimi (nt direct -> proxied)
ords --config /etc/ords/config config --db-pool default set plsql.gateway.mode proxied

# Muuda staatiliste failide asukohta
ords --config /etc/ords/config config set standalone.static.path /opt/ords/apex/images

# Systemd teenuse oleku kontroll ja taaskäivitamine
sudo systemctl status ords
sudo systemctl restart ords
```

---

## 🌐 Testimise ja Kasutamise Aadressid

Pärast paigaldamist on eraldiseisev ORDS teenus kättesaadav järgmistel aadressidel:

* **ORDS Landing Page (HTTP):** `http://<server-ip>:8080/ords/`
* **APEX Builder / Tööruum (HTTP):** `http://<server-ip>:8080/ords/apex`
* **ORDS Landing Page (HTTPS):** `https://<server-ip>:8443/ords/`
* **APEX Builder / Tööruum (HTTPS):** `https://<server-ip>:8443/ords/apex`
