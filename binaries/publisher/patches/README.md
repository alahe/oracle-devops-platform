# 🩹 Oracle Analytics Publisher Patches (`binaries/publisher/patches/`)

Sellesse kataloogi asetatakse Oracle Analytics Publisheri (Pixel Perfect / OAS / BIP) OPatchi `.zip` paketid ja SPB arhiivid.

## 📁 Kataloogi Struktuur

```
binaries/publisher/patches/
├── README.md                     # Käesolev juhend
└── pXXXXXXX_141200_Generic.zip   # Nt: Analytics Publisher OPatchi arhiiv
```

## 🚀 Paigaldamine

Automaatne paigaldus Analytics Publisheri konteineris:
```bash
./scripts/internal/apply-publisher-patch.sh binaries/publisher/patches/pXXXXXXX.zip
```

## 🔒 Git Versioonihalduse Reegel
- `.zip` arhiivid on `.gitignore` failis ega jõua Git repositooriumisse.
- Kataloogi struktuur ja `README.md` on versioonihaldusega tagatud.
