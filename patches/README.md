# 🩹 Oracle Patches Directory (`./patches`)

> [!NOTE]
> Tootespetsiifilised patchid asuvad vastava toote alamkataloogis:
> - **Oracle APEX:** [`binaries/apex/patches/`](../binaries/apex/patches/)
> - **Oracle Forms 14c:** [`binaries/forms/patches/`](../binaries/forms/patches/)
> - **Oracle Analytics Publisher:** [`binaries/publisher/patches/`](../binaries/publisher/patches/)
> - **Oracle Middleware / WebLogic:** [`binaries/middleware/patches/`](../binaries/middleware/patches/)
> - **Oracle Java / JDK:** [`binaries/java/patches/`](../binaries/java/patches/)
>
> Käesolev `./patches` kataloog säilitatakse tagasiühilduvuse ja universaalsete patchide jaoks.

## APEXi Patchi Paigaldamine
```bash
./scripts/internal/apply-apex-patch.sh binaries/apex/patches/p39179920_261_Generic.zip
```

## Analytics Publisheri Patchi Paigaldamine
```bash
./scripts/patches/apply-publisher-patch.sh binaries/publisher/patches/<patch_file>.zip
```
