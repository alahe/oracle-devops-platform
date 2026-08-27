# ORDS Tarkvarapakettide Kaust (`binaries/ords/`)

Sellesse kausta talletatakse kohalikud ja allalaaditud Oracle REST Data Services (ORDS) ZIP-paigalduspaketid.

## 📦 Toetatud Failinimed:
- `ords-latest.zip` (Vaikimisi värskeim stabiilne versioon)
- `ords-*.zip` (Versioonispetsiifilised paketid)

## ⚙️ Kuidas Töötab:
1. Skriptid `scripts/setup-all.sh` ja `scripts/internal/install-ords-standalone.sh` kontrollivad esmalt selle kausta sisu.
2. Kui kehtiv ZIP on olemas, kasutatakse seda otse ORDS konteineri või standalone instantsi käivitamiseks.
3. Kui fail puudub, laetakse vajalik versioon alla aktiivse YAML profiili parameetrist `PROFILE_ORDS_DOWNLOAD_URL`.
