[ 🇬🇧 English ](../database-image-switching-guide.md) | [ 🇪🇪 Eesti ](database-image-switching-guide.md) | [ 🇫🇮 Suomi ](../fi/database-image-switching-guide.md) | [ 🇸🇪 Svenska ](../sv/database-image-switching-guide.md) | [ 🇱🇻 Latviešu ](../lv/database-image-switching-guide.md) | [ 🇱🇹 Lietuvių ](../lt/database-image-switching-guide.md)

# 🔄 Andmebaasi Konteineripiltide Vahetamine ja Tarnijate Juhend

See juhend selgitab, kuidas vahetada Oracle 23ai konteineripilte, testida kogukonna vs ametlikke versioone, lukustada siseandmebaaside veebiliideseid ja säästa vahemälu.

---

## 🎯 1. Toetatud Baaspildid ja Rollid

Platvorm toetab kahte välise tarnija baaspilti ning lokaalset FastStart kihti:

| Pildi Nimi | Tarnija & Allikas | Roll | Peamised Blueprintid |
| :--- | :--- | :--- | :--- |
| `container-registry.oracle.com/database/free:latest` | **Oracle Ametlik (OCR)** | Kanooniline toodangu baastase | **Kõik Standard Blueprintid (1–6, 10–34)** |
| `docker.io/gvenzl/oracle-free:latest` | **Gerald Venzl (Docker Hub)** | Kiirete turvapaikadega kogukonnapilt | **Blueprint #7 (Alternatiivse Pildi Test)** |
| `localhost/oracle-free-apex:23ai-apex26.1` | **FastStart Kuldne Baas** | Eelküpsetatud APEX 26.1 kiht (0s paigaldust) | **Jagatud Kõigi DB Profiilide Vahel** |

---

## 🚀 2. Kuidas Vahetada Andmebaasi Pilti (3 Meetodit)

### Meetod A: Ühe Käsuga läbi Blueprinti #7
Docker Hubi alternatiivse baaspildi testimiseks kõrvuti ametlikuga:
```bash
./scripts/deploy-blueprint.sh 7
```

### Meetod B: Keskkonnamuutujaga ülekatmine (CLI)
Konteineripildi dünaamiline asendamine ilma faile muutmata:
```bash
ORACLE_CONTAINER_IMAGE="docker.io/gvenzl/oracle-free:latest" ./scripts/setup-all.sh -b 3 --fast
```

### Meetod C: Deklaratiivne YAML Profiili Seadistus
Andmebaasi profiili failis (nt `config/profiles/databases/db-proxy-oracle.yaml`):
```yaml
database:
  container_image: "container-registry.oracle.com/database/free:latest"
```

---

## 🔒 3. Siseandmebaaside Turvalukustus (`--lock-internal-apex`)

Mitme andmebaasiga virnades (nt Blueprint #21, #23) koos siseandmebaasidega (`db-forms`, `db-publisher`):
```bash
./scripts/setup-all.sh -b 23 --lock-internal-apex --fast
```
**Mis andmebaasis toimub:**
1. Mõlemad andmebaasid käivituvad välkkiirelt samalt FastStart baaspildilt.
2. `db-forms` ja `db-publisher` andmebaasides lukustatakse `APEX_PUBLIC_USER` ja `APEX_LISTENER` kontod (`ACCOUNT LOCK`).
3. ORDS veebiruutingut nendele andmebaasidele ei looda, tagades **100% sisevõrgu isolatsiooni**.

---

## ⚡ 4. Kiirtestimise ja Ühekordse Läbimise Lipud

| Lipp | Skript | Kirjeldus |
| :--- | :--- | :--- |
| `--fast` / `--skip-tests` | `setup-all.sh`, `deploy-blueprint.sh` | Jätab vahele paigaldusjärgsed E2E diagnostikakontrollid (~30–45s sääst) |
| `--snapshot-mode base` | `setup-all.sh` | Loob puhta andmebaasi baastõmmise enne rakenduste paigaldust |
| `--snapshot-mode release` | `setup-all.sh` | Loob täieliku tõmmise koos paigaldatud rakendusega (vaikimisi) |
| `--single-pass` / `--pass1-only` | `run_blueprint_matrix_test.sh` | Teeb ainult Pass 1 külmpaigalduse (~1.5h sääst CI-s) |
| `--unified-middleware` | `setup-all.sh` | Käivitab ühendatud Forms+Publisher konteineri (50% RAM-i sääst) |
