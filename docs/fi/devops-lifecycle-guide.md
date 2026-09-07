[ 🇬🇧 English ](../devops-lifecycle-guide.md) | [ 🇪🇪 Eesti ](../et/devops-lifecycle-guide.md) | [ 🇫🇮 Suomi ](devops-lifecycle-guide.md) | [ 🇸🇪 Svenska ](../sv/devops-lifecycle-guide.md) | [ 🇱🇻 Latviešu ](../lv/devops-lifecycle-guide.md) | [ 🇱🇹 Lietuvių ](../lt/devops-lifecycle-guide.md)

# 🔄 Konttivedosten, tilannevedosten ja varmuuskopioiden elinkaariopas

Tämä opas kuvaa alustan **3-tasoisen katastrofipalautus- ja pikakäynnistysmallin (FastPath)**:
1. **Konttivedokset (Images):** Muuttumaton käyttöjärjestelmä, kirjastot ja ohjelmistoytimet.
2. **Kultaiset Tilannevedokset (Golden Snapshots):** Tietokannan koko tilan vedos ~15 sekunnin palautukseen.
3. **Varmuuskopiot (Backups):** Komponenttikohtaiset viennit (Publisher-luettelo, SEPS Wallet, SQL-tiedostot).

---

## 🛠️ Pikakomennot

```bash
# 1. Palauta Golden Snapshot (~15s):
./scripts/snapshots/restore-golden-snapshots.sh -b 3

# 2. Luo uusi Golden Snapshot:
./scripts/snapshots/create-golden-snapshots.sh -b 3
```
