[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📋 Oracle DevOps Platform — Utvecklings- och Uppgiftsbacklog

Denna katalog rymmer plattformens modulära **backlogg-system**, där arkitekturförbättringar, funktioner och säkerhetskomponenter dokumenteras som Markdown-filer.

---

## 🧭 Struktur och Livscykelregler

```text
backlog/
├── README.md               # Regler och statusmatris
├── template.md             # Standardmall för nya uppgifter
├── todo/                   # Planerade och pågående uppgifter
└── done/                   # Färdigställda och verifierade funktioner
```

### Arbetsflöde:
1. **Ny uppgift:** Kopiera `template.md` till `todo/` som `TASK-XXX-[namn].md`.
2. **Starta:** Ange status till `IN_PROGRESS`.
3. **Slutför:** Flytta filen till `done/` (`mv backlog/todo/TASK-XXX-*.md backlog/done/`).
