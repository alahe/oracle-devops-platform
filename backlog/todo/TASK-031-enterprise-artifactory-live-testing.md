# [TASK-031]: Ettevõtte Sise-Artifactory Live-Ühenduse ja Piltide Pushimise Valideerimine

**Staatus:** `TODO`  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `Tooling` | `Infrastructure`  
**Seotud Blueprintid / Profiilid:** Kõik blueprintid (1–13)  
**Dokumentatsioon:** [docs/artifactory-setup.md](../../docs/artifactory-setup.md), [scripts/README.md](../../scripts/README.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Kuigi platvormil on olemas täielik Artifactory piltide avaldaja ([`scripts/publish-image-to-artifactory.sh`](../../scripts/publish-image-to-artifactory.sh)) ja selle `--dry-run` simulatsioonitestid läbivad 100%, puudub kohalikus arendusmasinas otsene võrguühendus ettevõtte reaalsesse JFrog Artifactory / Harbor / Nexus serverisse.

---

## 2. Eesmärk ja Oodatav Tulemus
Kui ettevõtte sisevõrgu VPN ja Artifactory autentimistunnused (API token / parool) on kättesaadavad, teostada reaalne live-katsetus:
1. Autentimine ja pildi üleslaadimine (`podman push`).
2. Sisevõrgu peegelduse (`REGISTRY_PREFIX`) valideerimine teises puhtas masinas või CI/CD runneris.

---

## 3. Tehniline Teostusplaan (Live Test Checklist)

1. **VPN ja Võrguühenduse Kontroll:**
   * Veenduda, et sihtregister (nt `artifactory.ettevote.ee`) vastab pingile/HTTPS-ile.
2. **Pildi Ehitamine ja Avaldamine:**
   ```bash
   # 1. Ehita kohalik pilt:
   ./scripts/setup-all.sh -b 3 --build-image

   # 2. Lae pilt ettevõtte Artifactorysse:
   ./scripts/publish-image-to-artifactory.sh \
     --registry "artifactory.ettevote.ee/docker-local/oracle" \
     --image "oracle-free-apex:23ai-apex26.1" \
     --user "$ARTIFACTORY_USER" \
     --password "$ARTIFACTORY_TOKEN" \
     --update-env
   ```
3. **Paigalduse Kontroll Puhtas Masinas:**
   ```bash
   ./scripts/reset-all.sh -y
   ./scripts/setup-all.sh -b 3
   ```
   * Kinnitada, et Podman tõmbab pildi otse Artifactoryst 10–20 sekundiga ja paigaldus lõpeb ilma välist internetti vajamata.

---

## 4. Verifitseerimine
- Kontrollida Artifactory veebiliidesest pildi olemasolu ja JFrog Xray turvaraportit.
- Mõõdikud: `metrics/setup_benchmarks.json` kinnitab alla 1–2 min paigalduse aega.
