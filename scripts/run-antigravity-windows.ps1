# ============================================================================
# Google Antigravity & Web IDE Windows Enterprise Podman Launcher
# Run this script on Windows 10/11 Enterprise via PowerShell.
# Keeps your Windows OS 100% clean - all tools run inside Podman container.
# Usage: powershell -ExecutionPolicy Bypass -File .\scripts\run-antigravity-windows.ps1
# ============================================================================

$ErrorActionPreference = "Stop"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "🚀 GOOGLE ANTIGRAVITY WINDOWS ENTERPRISE PODMAN LAUNCHER" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan

# 1. Kontrollime Podmani olemasolu Windows masinas
if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Viga: Podman ei ole Windowsi käsurealt kättesaadav." -ForegroundColor Red
    Write-Host "👉 Veendu, et Podman Desktop või WSL2 Podman on aktiivne." -ForegroundColor Yellow
    Exit 1
}

# 2. Seadistame .env faili kui see puudub
if (-not (Test-Path ".env")) {
    Write-Host "📋 Loon vaikimisi .env faili näidisfailist .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
}

# 3. Käivitame Web IDE ja Antigravity Podman konteinerid
Write-Host "🚀 Käivitan isoleeritud Podman konteineri (web-ide-dev)..." -ForegroundColor Green
podman-compose -f podman-compose.yml --profile web-ide up -d

Write-Host "⌛ Ootan konteineri käivitumist..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# 4. Sünkroniseerime seadistused konteineri sees
podman exec -i web-ide-dev /app/code-server/bin/code-server --install-extension google.geminicodeassist 2>$null
podman exec -i web-ide-dev /app/code-server/bin/code-server --install-extension continue.continue 2>$null
podman exec -u root -i web-ide-dev bash -c "chown -R abc:abc /config/.local /config/.config 2>/dev/null" 2>$null

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "🎉 GOOGLE ANTIGRAVITY ON KÄIVITATUD PODMANIS!" -ForegroundColor Green
Write-Host "👉 Ava brauseris (Edge/Chrome): http://localhost:8090" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan

# 5. Avame brauseri automaatselt
Start-Process "http://localhost:8090"
