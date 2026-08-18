# VS Code Laienduste Kaust (`binaries/extensions/`) & Google Antigravity

Siia kausta saavad arendajad ja administraatorid asetada kohalikud VS Code `.vsix` laienduste paketid.

Skript `scripts/internal/init-web-ide.sh` otsib Web IDE konteineri käivitumisel siit kaustast kõiki `.vsix` faile ja paigaldab need automaatselt veebipõhisesse VS Code keskkonda.

---

## 🤖 Google Antigravity Eraldiseisev Paigaldus

> [!NOTE]
> **Google Antigravity** on eraldiseisev tehisintellekti koodiassistent (Standalone Agent / CLI tool), mida ei paigaldata tavalise VS Code laiendusena.
> 
> **Konteineri tugi:**
> - Google Antigravity on paigaldatud eraldiseisva rakendusena otse Web IDE konteinerisse (`https://antigravity.google/`).
> - Arendaja saab seda käivitada otse Web IDE terminalist käskudega `antigravity`.

---

## 📦 Kohalikud VS Code VSIX Laiendused
Tavaliste VS Code laienduste lokaalseks lisamiseks:
1. Aseta soovitud `.vsix` fail kausta `binaries/extensions/`.
2. Käivita `./scripts/start-containers.sh` või `./scripts/setup-all.sh`.
3. Laiendus installeeritakse automaatselt veebipõhisesse VS Code keskkonda.
