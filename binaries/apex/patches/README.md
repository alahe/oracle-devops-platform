# 🩹 Oracle APEX Patches Directory (`binaries/apex/patches/`)

Sellesse kataloogi asetatakse Oracle APEXi paigaldusjärgsete patchide (Bundle Patch / PSE / One-off Patch) `.zip` failid.

## 📁 Kataloogi Struktuur

```
binaries/apex/patches/
├── README.md                     # Käesolev juhend
└── p39179920_261_Generic.zip     # Nt: APEX 26.1.4 PSE Bundle Patch (Bug 39179920)
```

## 🚀 Automaatne ja Käsitsi Paigaldamine

1. **Automaatne tuvastus:** `setup-all.sh` / `scripts/internal/install-apex.sh` skannib selle kataloogi automaatselt APEX-i paigalduse järel (Samm 5).
2. **Käsitsi paigaldus:**
   ```bash
   ./scripts/internal/apply-apex-patch.sh binaries/apex/patches/p39179920_261_Generic.zip
   ```

## 🔒 Git Versioonihalduse Reegel
- `.zip` arhiivid on `.gitignore` failis ega jõua Git repositooriumisse.
- Kataloogi struktuur ja `README.md` on versioonihaldusega tagatud.
