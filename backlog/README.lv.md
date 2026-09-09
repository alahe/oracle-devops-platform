[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📋 Oracle DevOps platform — izstrādes un uzdevumu žurnāls (backlog)

Šis direktorijs satur platformas modulāro **uzdevumu žurnāla (Backlog) sistēmu**, kur arhitektūras uzlabojumi, funkcijas un drošības komponenti tiek dokumentēti Markdown failos.

---

## 🧭 Struktūra Un Dzīves cikla noteikumi

```text
backlog/
├── README.md               # Noteikumi un statusa matrica
├── template.md             # Standarta veidne jauniem uzdevumiem
├── todo/                   # Plānotie un aktīvie uzdevumi
└── done/                   # Pabeigtās un verificētās funkcijas
```

### Darbplūsma:
1. **Jauns uzdevums:** Kopēt `template.md` mapē `todo/` kā `TASK-XXX-[nosaukums].md`.
2. **Sākt darbu:** Iestatīt statusu uz `IN_PROGRESS`.
3. **Pabeigšana:** Pārvietot failu uz `done/` (`mv backlog/todo/TASK-XXX-*.md backlog/done/`).
