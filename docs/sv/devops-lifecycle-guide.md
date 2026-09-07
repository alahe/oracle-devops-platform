[ 🇬🇧 English ](../devops-lifecycle-guide.md) | [ 🇪🇪 Eesti ](../et/devops-lifecycle-guide.md) | [ 🇫🇮 Suomi ](../fi/devops-lifecycle-guide.md) | [ 🇸🇪 Svenska ](devops-lifecycle-guide.md) | [ 🇱🇻 Latviešu ](../lv/devops-lifecycle-guide.md) | [ 🇱🇹 Lietuvių ](../lt/devops-lifecycle-guide.md)

# 🔄 Guide för behållaravbildningar, ögonblicksbilder och säkerhetskopior

Denna guide beskriver plattformens **3-nivåers katastrofåterställnings- och snabbstartsmodell (FastPath)**:
1. **Behållaravbildningar (Images):** Oföränderligt OS och körtidsmotorer.
2. **Gyllene Ögonblicksbilder (Golden Snapshots):** Databasvolymdumpar för ~15s snabbåterställning.
3. **Säkerhetskopior (Backups):** Exporter av Publisher-katalog, SEPS Wallet och SQL-filer.

---

## 🛠️ Snabbkommandon

```bash
# 1. Återställ Golden Snapshot (~15s):
./scripts/snapshots/restore-golden-snapshots.sh -b 3

# 2. Skapa ny Golden Snapshot:
./scripts/snapshots/create-golden-snapshots.sh -b 3
```
