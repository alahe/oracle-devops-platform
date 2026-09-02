[ 🇬🇧 English ](../devops-lifecycle-guide.md) | [ 🇪🇪 Eesti ](../et/devops-lifecycle-guide.md) | [ 🇫🇮 Suomi ](../fi/devops-lifecycle-guide.md) | [ 🇸🇪 Svenska ](../sv/devops-lifecycle-guide.md) | [ 🇱🇻 Latviešu ](devops-lifecycle-guide.md) | [ 🇱🇹 Lietuvių ](../lt/devops-lifecycle-guide.md)

# 🔄 Konteineru Attēlu, Momentuzņēmumu un Dublējumu Dzīvescikla Rokasgrāmata

Šī rokasgrāmata apraksta platformas **3 līmeņu avārijas atjaunošanas un FastPath modeli**:
1. **Konteineru Attēli (Images):** Nemainīga OS un programmatūras dzinēji.
2. **Zelta Momentuzņēmumi (Golden Snapshots):** Pilns datubāzes stāvokļa uzņēmums ~15s atjaunošanai.
3. **Dublējumi (Backups):** Komponentu eksports (Publisher katalogs, SEPS Wallet, SQL faili).

---

## 🛠️ Ātrās Komandas

```bash
# 1. Atjaunot Golden Snapshot (~15s):
./scripts/snapshots/restore-golden-snapshots.sh -b 3

# 2. Izveidot jaunu Golden Snapshot:
./scripts/snapshots/create-golden-snapshots.sh -b 3
```
