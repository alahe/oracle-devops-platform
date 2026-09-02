# 🩹 Oracle Fusion Middleware / WebLogic Patches (`binaries/middleware/patches/`)

Sellesse kataloogi asetatakse Oracle Fusion Middleware Infrastructure / WebLogic 14c Stack Patch Bundle (SPB) ja OPatch paketid.

## 📁 Kataloogi Struktuur

```
binaries/middleware/patches/
├── README.md                     # Käesolev juhend
└── pXXXXXXX_141200_Generic.zip   # Nt: WebLogic 14c PSU / SPB arhiiv
```

## 🚀 Paigaldamine

Patche rakendatakse WebLogic / FMW infrastruktuuris OPatchi vahendusel (`opatch apply`).

## 🔒 Git Versioonihalduse Reegel
- `.zip` arhiivid on `.gitignore` failis ega jõua Git repositooriumisse.
- Kataloogi struktuur ja `README.md` on versioonihaldusega tagatud.
