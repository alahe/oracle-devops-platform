# ============================================================================
# Oracle DevOps Platform - Windows User Certificate Installer (PowerShell)
# Lisab kohaliku Dev Root CA Windowsi jooksva kasutaja usaldusvaarsesse hoidlasse.
# Toimib 100% tavakasutaja oigustes (0-Root / No Admin / No UAC prompt).
# ============================================================================

[CmdletBinding()]
param()

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Resolve-Path (Join-Path $ScriptDir "..\..")
$CertFile = Join-Path $RootDir "config\certs\localCA.pem"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  ORACLE DEVOPS PLATFORM - SERTIFIKAADI USALDAMINE (POWERSHELL)" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

if (-not (Test-Path $CertFile)) {
    Write-Host "[VIGA] Sertifikaati ei leitud asukohast: $CertFile" -ForegroundColor Red
    Write-Host "Palun kaivita esmalt keskkonna seadistus: ./scripts/setup-all.sh"
    exit 1
}

Write-Host "[INFO] Lisame sertifikaadi Windowsi jooksva kasutaja hoidlasse (Cert:\CurrentUser\Root)..." -ForegroundColor Yellow

try {
    # Kasutame certutil -user meetodit, mis on koige universaalsem ja 0-admin
    $res = certutil -user -addstore Root "$CertFile"
    Write-Host ""
    Write-Host "==================================================================" -ForegroundColor Green
    Write-Host "[EDUKAS] Sertifikaat 'Local Dev Root CA' on edukalt usaldatud!" -ForegroundColor Green
    Write-Host "         Brauserid (Chrome, Edge) avavad nuud HTTPS lingid" -ForegroundColor Green
    Write-Host "         (nt https://localhost:8448/ords/) ilma hoiatusteta!" -ForegroundColor Green
    Write-Host "==================================================================" -ForegroundColor Green
} catch {
    Write-Host "[VIGA] Sertifikaadi lisamine ebaonnestus: $_" -ForegroundColor Red
    exit 1
}
