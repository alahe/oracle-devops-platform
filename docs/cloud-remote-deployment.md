# ☁️ Kaug-Serverite Pilvepaigalduse Juhend (OCI Always Free, Azure & GitHub Actions)

See juhend kirjeldab samm-sammult, kuidas paigaldada ja käitada Oracle Free DB, APEX, ORDS ja Analytics Publisher lahendust **OCI (Oracle Cloud Infrastructure) Always Free** ja **Azure Free** Linux serverites ning kuidas seadistada **GitHub Actions CI/CD** automaatne paigaldus.

---

## 🚀 1. OCI Always Free Tier Seadistamine (Soovituslik - 100% Tasuta)

Oracle Cloud pakub **Always Free** raames äärmiselt võimsat **Ampere A1 (ARM64)** virtuaalmasinat (kuni 4 OCPU ja 24 GB RAM), mis on tasuta ning täiesti piisav kogu Publisheri ja andmebaasi stacki käitamiseks.

### Samm 1.1: Virtuaalmasina (Compute Instance) loomine
1. Logi sisse oma OCI kontole ([cloud.oracle.com](https://cloud.oracle.com/)).
2. Vali menüüst: **Compute -> Instances -> Create Instance**.
3. **Image ja Shape:**
   - Image: `Oracle Linux 8` või `Oracle Linux 9`.
   - Shape: Vali `Change Shape` -> **Ampere (Arm)** -> `VM.Standard.A1.Flex` -> Vali **4 OCPU-d ja 24 GB RAM-i** *(Always Free Eligible)*.
4. **SSH Keys:**
   - Vali `Upload public key files` ja laadi üles oma lokaalse arvuti SSH avalik võti (`~/.ssh/id_ed25519.pub` või `~/.ssh/id_rsa.pub`).
5. Vajuta **Create**.

### Samm 1.2: OCI Tulemüür (Security List Ingress Rules)
1. Mine luuaud instantsi lehele ja klõpsa alamvõrgul (**Public Subnet**).
2. Vali **Security Lists** -> Klõpsa **Default Security List for...**.
3. Lisa järgmised **Ingress Rules**:

| Allikas (Source) | Protokoll | Pordi Vahemik | Kirjeldus |
| :--- | :--- | :--- | :--- |
| `<SINU_AVALIK_IP>/32` | TCP | `22` | SSH Ligipääs (Turvaliselt filtreeritud) |
| `0.0.0.0/0` | TCP | `9502` | Oracle Analytics Publisher UI |
| `0.0.0.0/0` | TCP | `8088` | ORDS / APEX Veebiliides |
| `0.0.0.0/0` | TCP | `9500` | WebLogic Remote Console REST API |

---

## 🔷 2. Azure Free Account Seadistamine (Alternatiiv)

1. Logi sisse **Azure Portalisse** ([portal.azure.com](https://portal.azure.com/)).
2. Vali **Virtual Machines -> Create -> Azure virtual machine**.
3. **Basics:**
   - VM name: `oracle-publisher-vm`
   - Image: `Ubuntu Server 22.04 LTS` või `AlmaLinux 9`.
   - Size: `Standard_B2s` (2 vCPU, 4 GB RAM).
   - Authentication type: `SSH public key`, username: `azureuser`.
4. **Networking (NSG Inbound Port Rules):**
   - Ava pordid `22` (SSH), `9502` (Publisher) ja `8088` (ORDS).

---

## 💻 3. Automaatne Paigaldus Käsuga `./scripts/deploy-remote.sh`

Kui kaug-server on loodud ja IP teada (nt `130.61.12.34`):

```bash
# Paigalda lokaalsest masinast kaug-serverisse ühe käsuga:
./scripts/deploy-remote.sh --host 130.61.12.34 --user opc --key ~/.ssh/id_ed25519 --profile publisher-only
```

**Mida skript automaatselt teeb:**
1. Ühendub üle SSH kaug-serverisse.
2. Paigaldab vajadusel `podman`-i, `git`-i ja `curl`-i.
3. Avab serveri Linux tulemüüris pordid 9502, 9500, 8448 ja 8088 (`firewall-cmd`).
4. Sünkroniseerib koodi ja käivitab peaskripti `./scripts/setup-all.sh -y`.

---

## 🌐 4. Multi-Cloud Arhitektuur (Azure VM + OCI Autonomous Database)

Kui andmebaas asub OCI Pilves (Autonomous Database Serverless) ja rakenduskiht (ORDS / Publisher) Azure Linux virtuaalmasinas:
* Vaata detailset samm-sammulist juhendit: **[docs/remote-multicloud-setup-guide.md](remote-multicloud-setup-guide.md)** (eesti keeles: **[docs/et/remote-multicloud-setup-guide.md](et/remote-multicloud-setup-guide.md)**).
* Valideeri paigaldust automaatse testskriptiga:
  ```bash
  ./tests/test-remote-multicloud.sh --azure-ip <AZURE_IP> --oci-ip <OCI_IP> --db-alias DB_ADB_ADMIN
  ```

---

## 🤖 5. GitHub Actions CI/CD Seadistamine

Kui kood asub GitHubis, saab paigalduse automatiseerida iga uue `git push main` korral!

### Samm 4.1: Lisa GitHub Secrets
Mine oma repositooriumi lehele: **Settings -> Secrets and variables -> Actions -> New repository secret**:

| Secret Nimi | Väärtus |
| :--- | :--- |
| `REMOTE_HOST` | Pilveserveri avalik IP (nt `130.61.12.34`) |
| `REMOTE_USER` | `opc` (OCI) või `azureuser` / `ubuntu` (Azure) |
| `REMOTE_SSH_KEY` | SSH privaatvõtme sisu (`cat ~/.ssh/id_ed25519`) |

### Samm 4.2: Töövoo Käivitamine
Töövoog [.github/workflows/deploy-remote-cloud.yml](../.github/workflows/deploy-remote-cloud.yml) käivitub automaatselt `push` korral või käsitsi vahekaardilt **Actions -> ☁️ Remote Cloud Deployment -> Run workflow**.
