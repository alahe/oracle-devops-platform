[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📋 Oracle DevOps platform — vystymo ir Užduočių Sąrašas (backlog)

Šiame kataloge yra platformos modulinė **užduočių sąrašo (Backlog) sistema**, kurioje architektūriniai patobulinimai, funkcijos ir saugumo komponentai dokumentuojami Markdown failuose.

---

## 🧭 Struktūra Ir gyvavimo ciklo Taisyklės

```text
backlog/
├── README.md               # Taisyklės ir būsenos matrica
├── template.md             # Standartinis šablonas naujoms užduotims
├── todo/                   # Planuojamos ir vykdomos užduotys
└── done/                   # Įgyvendintos ir patvirtintos funkcijos
```

### Darbo eiga:
1. **Nauja užduotis:** Nukopijuoti `template.md` į `todo/` kaip `TASK-XXX-[pavadinimas].md`.
2. **Pradžia:** Nustatyti būseną `IN_PROGRESS`.
3. **Pabaiga:** Perkelti failą į `done/` (`mv backlog/todo/TASK-XXX-*.md backlog/done/`).
