[ 🇬🇧 English ](../devops-lifecycle-guide.md) | [ 🇪🇪 Eesti ](../et/devops-lifecycle-guide.md) | [ 🇫🇮 Suomi ](../fi/devops-lifecycle-guide.md) | [ 🇸🇪 Svenska ](../sv/devops-lifecycle-guide.md) | [ 🇱🇻 Latviešu ](../lv/devops-lifecycle-guide.md) | [ 🇱🇹 Lietuvių ](devops-lifecycle-guide.md)

# 🔄 Konteinerių paveikslėlių, momentinių kopijų ir atsarginių kopijų vadovas

Šis vadovas aprašo platformos **3 lygių atkūrimo po avarijų ir FastPath modelį**:
1. **Konteinerių Paveikslėliai (Images):** Nekintama OS ir vykdymo varikliai.
2. **Auksinės Momentinės Kopijos (Golden Snapshots):** Duomenų bazės būsenos kopija ~15s atkūrimui.
3. **Atsarginės Kopijos (Backups):** Komponentų eksportai (Publisher katalogas, SEPS Wallet, SQL failai).

---

## 🛠️ Greitosios komandos

```bash
# 1. Atkurti Golden Snapshot (~15s):
./scripts/snapshots/restore-golden-snapshots.sh -b 3

# 2. Sukurti naują Golden Snapshot:
./scripts/snapshots/create-golden-snapshots.sh -b 3
```
