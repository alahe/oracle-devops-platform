---
name: oracle_containers_devops
description: Juhis Oracle andmebaasi ja utiliidikonteinerite (SQLcl, ORDS, Free DB) kasutamiseks Oracle Container Registry (OCR) kaudu ja nende tarnimiseks Kubernetesesse/konteinerplatvormidele.
---

# Oracle Containers for DevOps: Andmebaas ja Tööriistad Konteineris

See skill juhendab, kuidas kasutada ametlikke Oracle andmebaasi ja utiliitide konteinereid (SQLcl, ORDS, Oracle Free Database) arenduseks ja automaatseks tarnimiseks (DevOps) Kubernetesesse ja teistele konteinerplatvormidele.

---

## 1. Oracle Container Registry (OCR) ja Autentimine

Kõik ametlikud Oracle konteineri pildid asuvad Oracle Container Registry-s. Enne piltide tõmbamist peab arendaja või CI/CD runner olema registrisse sisse logitud.

### Autentimise sammud:
1. Ava [Oracle Container Registry](https://container-registry.oracle.com/) ja nõustu litsentsitingimustega (EULA) vajalike toodete all (nt Database, SQLcl).
2. Logi käsureal sisse oma Oracle Single Sign-On (SSO) kontoga:
```bash
podman login container-registry.oracle.com
```

---

## 2. Ametlikud Konteineri Pildid (Image Paths)

| Konteiner | Registri tee (Image URI) | Kirjeldus |
| :--- | :--- | :--- |
| **Oracle Database Free** | `container-registry.oracle.com/database/free:latest` | Täisfunktsionaalne tasuta andmebaas (23ai / 26ai). |
| **Oracle SQLcl** | `container-registry.oracle.com/database/sqlcl:latest` | SQL käsurida ja andmebaasi elutsükli haldus (Liquibase/Projects). |
| **Oracle ORDS** | `container-registry.oracle.com/database/ords:latest` | REST liides ja APEX-i staatiliste ressursside vahendaja. |

---

## 3. Konteinerite Kasutamine Arenduses (Podman / Docker)

Ühekordsete utiliitide (nagu SQLcl) käivitamisel kohalikus masinas või CI/CD-s on soovitatav kasutada **ajutiste (ephemeral) konteinerite** mustrit:

### Käivituse parameetrid:
*   `--rm`: Kustutab konteineri automaatselt pärast töö lõppu, säästes kettaruumi ja ennetades WSL-i rippuma jäävaid sessioone.
*   `--network=host`: Võimaldab konteineril suhelda host-masina portidega (nt andmebaasiga pordil `1532`).
*   `-v "$(pwd):/workspace"`: Mountib praeguse Giti repositooriumi juurkataloogi konteineri kausta `/workspace`.
*   `-w /workspace`: Määrab konteineri töökataloogiks `/workspace`, tagades suhteliste failiteede ühilduvuse.

### Näide: SQLcl käivitamine konteineris
```bash
podman run --rm -i \
  --network=host \
  -v "$(pwd):/workspace" \
  -w /workspace \
  container-registry.oracle.com/database/sqlcl:latest \
  APEX_PROXY_SCHEMA/password@localhost:1532/FREEPDB1
```

---

## 4. Tarnimine Kubernetesesse (Kubernetes Deployment)

Kui liigutakse test- või toodangukeskkonda, kirjeldatakse konteinerid deklaratiivselt Kubernetese ressurssidena (Deployments, ConfigMaps, Secrets).

### 1. Registri saladus (ImagePullSecret)
Selleks, et Kubernetes saaks pilte tõmmata Oracle registrist, tuleb luua spetsiaalne saladus:
```bash
kubectl create secret docker-registry ocr-regsecret \
  --docker-server=container-registry.oracle.com \
  --docker-username="sinu_oracle_sso_email" \
  --docker-password="sinu_oracle_sso_parool" \
  --docker-email="sinu_oracle_sso_email"
```

### 2. Podi kirjeldus (Deployment YAML)
Kasuta saladust oma YAML failis:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ords-deployment
spec:
  replicas: 2
  template:
    spec:
      imagePullSecrets:
        - name: ocr-regsecret
      containers:
        - name: ords
          image: container-registry.oracle.com/database/ords:latest
          ports:
            - containerPort: 8888
```

---

## 5. Kasulikud Viited (Useful Resources)

*   **Ametlik blogipostitus (DevOps & K8s):** [Oracle Database Containers for DevOps](https://blogs.oracle.com/database/post/oracle-database-containers-for-devops-from-oracle-container-registry-to-kubernetes) - Juhised ja parimad praktikad ametlike konteinerite viimiseks arendusest kuni toodangukõlbliku Kuberneteseni.
*   **Oracle Container Registry portaal:** [OCR Portal](https://container-registry.oracle.com/)

---

## 6. Podman Virtuaalmasina Pesa Taaskäivitamine & Veaotsing (Troubleshooting)

Kui Podman CLI teenus hangub, väljastab pesa viga `EOF` või konteiner ei saavuta `healthy` olekut 450s jooksul:

```bash
# 1. Peata ja käivita macOS / Linux Podman virtuaalmasin uuesti:
podman machine stop
podman machine start

# 2. Puhasta katkised mahud (volumes) ja konteinerid:
./scripts/reset-all.sh --force

# 3. Käivita keskkonna paigaldus uuesti:
./scripts/setup-all.sh --force
```

