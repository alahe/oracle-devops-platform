[ 🇬🇧 English ](../getting-started-from-scratch.md) | [ 🇪🇪 Eesti ](getting-started-from-scratch.md)

# 🚀 Kiirstardi juhend: kuidas alustada nullist (zero-to-hero)

See juhend õpetab **Oracle DevOps Platvormi** seadistamist täiesti puhtalt töökohalt (macOS, Windows 11 WSL2 või Linux).

> [!TIP]
> **Töötav Dev Hub on juba avatud?** Kui loed seda juhendit töötava Developer Hubi brauseriaknas, on sinu masin juba seadistatud! Sa ei pea neid samme uuesti läbi tegema. See juhend on mõeldud uute masinate seadistamiseks, uute tiimiliikmete sisseelamiseks või uue CI/CD serveri loomiseks.

---

## 📋 Nõuded Süsteemile

| Komponent | Miinimum | Soovitatav | Märkused |
| :--- | :--- | :--- | :--- |
| **RAM** | 8 GB | 16 GB+ | Oracle DB Free vajab ~2 GB; lisavirnad (APEX, ORDS, Forms, Publisher) vajavad 1–3 GB virna kohta. |
| **Kettaruum** | 20 GB vaba | 50 GB vaba | Konteineritõmmiste ja andmebaasi mahtude jaoks. |
| **Konteinerimootor** | Podman 4.5+ või Docker 24+ | Rootless Podman 5.x | Platvormi vaikesäte kasutab turvalist rootless Podmani. |
| **Terminal** | Bash 4.x / Zsh | Zsh / Bash | Git Bash või kohalik WSL2 Linuxi terminal Windowsis. |
| **VS Code** | Uusim | Uusim + laiendused | Oracle SQL Developer laiendus on soovitatav. |

---

## 💻 Samm-sammuline Paigaldus

### Samm 1: Klooni Koodihoidla (Clone Repo)

Klooni repositoorium oma kohalikku arvutisse:

```bash
git clone https://github.com/alahe/oracle-devops-platform.git
cd oracle-devops-platform
```

> [!WARNING]
> **Windowsi Kasutajad (WSL2 Nõutav):** Klooni ja käivita repositoorium **ALATI WSL2 natiivses Linuxi failisüsteemis** (`~/oracle-devops-platform`), **MITTE KUNAGI** Windowsi kettahaakel (`/mnt/c/...`). Windowsi kettahaake kasutamine aeglustab I/O kiirust 10x–50x ning rikub failiõigused (`chmod 0600`) SEPS Walletil.

---

### Samm 2: Ava VS Code'is

Ava projekt koodiredaktoris:

```bash
code .
```

Ava integreeritud terminal:
- **Windows / Linux:** `Ctrl + \``
- **macOS:** `Cmd + \``

---

### Samm 3: Kontrolli Eeldusi (Pre-Flight)

Käivita eelduste diagnostika:

```bash
# macOS või Linux:
./scripts/check-prerequisites.sh

# Windows (PowerShell või CMD):
.\setup.cmd --check
```

Kontrollitakse:
- Konteineriteenuse olemasolu (`podman` või `docker`)
- Vaba RAM ja protsessorituumad
- Pordid andmebaasile (1531–1537) ja veebiteenustele (8448, 8088, 9502, 6083)
- Windows Hyper-V reserveeritud pordid

---

### Samm 4: Käivita Automaatpaigaldus

Käivita automaatne orkestreerija:

```bash
# Vaikimisi Blueprint 1 (Database + APEX + ORDS):
./scripts/setup-all.sh -y
```

> [!NOTE]
> **Kestus:** Esmakordne külm paigaldus võtab tavaliselt 10–14 minutit (tõmmiste allalaadimine, PDB loomine, APEXi paigaldus ja Walleti krüpteerimine). Järgmised käivitused võtavad alla 15 sekundi.

---

### Samm 5: Usalda Kohalikku SSL Sertifikaati

Selleks, et brauser avaks `https://localhost:8448` ilma turvahoiatusteta:

```bash
# macOS:
./scripts/certs/trust-local-cert-mac.sh

# Windows (Zero-Admin / Administraatori õigusi pole vaja):
.\scripts\certs\trust-local-cert.cmd

# Linux:
sudo cp config/certs/ca.crt /usr/local/share/ca-certificates/oracle-local-ca.crt && sudo update-ca-certificates
```

---

### Samm 6: Ava Dev Hub Juhtpaneel

Ava Developer Hub oma brauseris:

```bash
# macOS:
open ./docs/dev-hub.html

# Linux:
xdg-open ./docs/dev-hub.html

# Windows:
start ./docs/dev-hub.html
```

Või ava otse HTTPS kaudu:
- **Developer Hub:** [https://localhost:8448/dev-hub](https://localhost:8448/dev-hub)
- **APEX Workspace:** [https://localhost:8448/ords/r/oracle/workspace](https://localhost:8448/ords/r/oracle/workspace)
- **Database Actions:** [https://localhost:8448/ords/sql-developer](https://localhost:8448/ords/sql-developer)

---

## 🔑 Paroolivaba CLI & SQLcl Ühendused

Platvorm kasutab **Oracle SEPS (Secure External Password Store)** auto-login walletit:

```bash
# Ühendu arendajana PDB-sse:
./scripts/sqlcl.sh /@DB_PROXY_DEV

# Ühendu administraatorina:
./scripts/sqlcl.sh /@DB_PROXY_ADMIN

# Vaata parooli mälust ilma faili salvestamata:
./scripts/get-password.sh DB_PROXY_DEV
```

---

## 🔄 Mitme Andmebaasivirna Halidus

Platvorm toetab **1, 2 või 3 andmebaasivirna samaaegset tööd**:
- Teise virna lisamine (nt Blueprint 3 LIS Database või Blueprint 4 Publisher) **ei võta olemasolevaid andmebaase maha**.
- Süsteem kontrollib enne käivitamist vaba RAM-i, tagades masina stabiilsuse.

---

## ❓ Korduma Kippuvad Küsimused & Ametlikud Allalaadimised

- Küsimused muutmälu, portide konfliktide, SSL sertifikaatide või kiirtaaste kohta? Vaata [Platvormi Korduma Kippuvad Küsimused (KKK)](faq.md).
- Otsid ametlikke Oracle konteineritõmmiseid või toodete allalaadimislinke? Vaata [Ametlikud Oracle Ressursid ja Konteineritõmmised](oracle-resources-and-downloads.md).
