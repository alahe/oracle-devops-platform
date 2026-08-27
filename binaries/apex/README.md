# APEX Tarkvarapakettide Kaust (`binaries/apex/`)

Sellesse kausta talletatakse kohalikud ja allalaaditud Oracle APEX ZIP-paigalduspaketid.

## 📦 Toetatud Failinimed:
- `apex-latest.zip` (Vaikimisi värskeim stabiilne versioon)
- `apex_26.1_en.zip` (Spetsiifiline APEX 26.1 ingliskeelne versioon)
- `apex_24.2.zip` (APEX 24.2 versioon)
- `apex_*.zip` (Igasugune muu versiooni zip-fail)

## ⚙️ Kuidas Töötab:
1. Skriptid `scripts/setup-all.sh` ja `scripts/internal/install-apex.sh` kontrollivad esmalt siit kaustast nõutud versiooni ZIP-arhiivi olemasolu.
2. Kui kehtiv ZIP on olemas, kasutatakse seda otse ja välistatakse uuesti allalaadimine.
3. Kui fail puudub, laetakse see aktiivse YAML profiili URL-ilt automaatselt siia kausta.
