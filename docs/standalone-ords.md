# Standalone ORDS Paigaldamine Linux Serverisse (või Podmani)

See dokument kirjeldab Oracle REST Data Services (ORDS) automaatse standalone teenuse paigaldamist ja konfigureerimist eraldiseisvasse Linux serverisse (või konteinerisse).

---

## Eeldused (Prerequisites)

*   **Java:** Serverisse peab olema paigaldatud Java 11 või 17.
*   **Võrguühendus:** Serverist peab olema pääs andmebaasile (TCPS port 2484 või standard port 1521/1522).
*   **Tarkvara:** Allalaadimise URL-id (nt sise-Artifactory või OTN) on seadistatavad failis `config/repository.env`.

---

## Automaatne paigaldamine (`install-ords-standalone.sh`)

ORDS-i paigaldamiseks ja seadistamiseks eraldi Linux serveris või lokaalses virtuaalmasinas käivita järgmine käsk:

```bash
# Käivita Linux serveris (seadista andmebaasi ühenduse andmed)
DB_HOST="db-apex-proxy-ip" \
DB_PORT=1521 \
DB_SERVICE="FREEPDB1" \
./scripts/internal/install-ords-standalone.sh
```

### Skripti teostatavad sammud:
1.  **Java kontroll:** Kontrollib, kas süsteemis on Java olemas.
2.  **Laadib alla tarkvara:** Tõmbab ORDS `.zip` faili konfigureeritud Artifactory või OTN aadressilt.
3.  **Paigaldab tarkvara:** Pakib ORDS-i lahti ja loob vajaliku kataloogistruktuuri.
4.  **Seadistab ühenduse:** Loob ühenduse konfiguratsiooni sihtandmebaasiga ja loob vajadusel `ORDS_METADATA` skeemi.
5.  **Seadistab teenuse (Systemd):** Registreerib ORDS-i Linuxi systemd teenusena, tagades automaatse käivitumise serveri taaskäivitusel.

---

## Testimise ja Kasutamise Aadressid

*   **ORDS Landing Page (HTTP):** `http://<server-ip>:8080/ords/`
*   **ORDS Landing Page (HTTPS):** `https://<server-ip>:8443/ords/`

---

## Konfigureeritavad portid ja seaded
Kõik ORDS-i konfiguratsiooniväärtused loetakse ja salvestatakse ORDS-i seadete kausta (vaikimisi `/etc/ords/config`). Seadeid saab muuta käsurealt:

```bash
# Gateway režiimi muutmine (nt direct -> proxied)
ords --config /etc/ords/config config --db-pool default set plsql.gateway.mode proxied

# Staatiliste failide asukoha muutmine
ords --config /etc/ords/config config set standalone.static.path /opt/ords/apex/images
```
