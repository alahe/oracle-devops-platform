# ==============================================================================
# Oracle DevOps Platform - Windows PowerShell Launcher (setup.ps1)
# Purpose: 1-Click launcher for PowerShell users delegating to WSL2 environment.
# Operates with 100% standard user privileges (0-Admin / No UAC required).
# ==============================================================================
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ScriptArgs
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  ORACLE DEVOPS PLATFORM - WINDOWS POWERSHELL LAUNCHER" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

# 1. Verify WSL availability
$wslCmd = Get-Command wsl.exe -ErrorAction SilentlyContinue
if (-not $wslCmd) {
    Write-Host "[ERROR] Windows Subsystem for Linux (wsl.exe) was not found!" -ForegroundColor Red
    Write-Host "Please ensure WSL2 is installed on your Windows machine." -ForegroundColor Yellow
    exit 1
}

# 2. Check if running from Windows NTFS mount
if ($ScriptDir -match '^[a-zA-Z]:\\') {
    Write-Host "[WARNING] Detected execution from Windows drive path ($ScriptDir)." -ForegroundColor Yellow
    Write-Host "          Accessing files via WSL2 /mnt/c/ causes a 10x-50x I/O slowdown!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[RECOMMENDATION] For optimal performance (APEX, ORDS, database builds):" -ForegroundColor Cyan
    Write-Host "   Clone and run this project inside the native WSL2 ext4 filesystem:" -ForegroundColor Cyan
    Write-Host "      1. wsl"
    Write-Host "      2. cd ~"
    Write-Host "      3. git clone <repo-url> oracle-free-db-in-prod"
    Write-Host "      4. cd oracle-free-db-in-prod && ./scripts/setup-all.sh"
    Write-Host ""
    Write-Host "Continuing execution in current location..." -ForegroundColor Gray
    Write-Host "==================================================================" -ForegroundColor Cyan
}

# 3. Build arguments and invoke WSL2
$argsString = ""
if ($ScriptArgs -and $ScriptArgs.Count -gt 0) {
    $argsString = ($ScriptArgs -join " ")
}

Write-Host "[INFO] Delegating execution to WSL2 Linux environment..." -ForegroundColor Yellow
Write-Host "[INFO] Command: ./scripts/setup-all.sh $argsString" -ForegroundColor Gray
Write-Host "==================================================================" -ForegroundColor Cyan

$wslProc = Start-Process -FilePath "wsl.exe" -ArgumentList "bash -lic './scripts/setup-all.sh $argsString'" -NoNewWindow -PassThru -Wait

if ($wslProc.ExitCode -eq 0) {
    Write-Host ""
    Write-Host "==================================================================" -ForegroundColor Green
    Write-Host "[SUCCESS] Environment setup completed successfully!" -ForegroundColor Green
    Write-Host "          To trust SSL certificates in Windows browsers, run:" -ForegroundColor Green
    Write-Host "          powershell -File scripts\certs\trust-local-cert.ps1" -ForegroundColor Green
    Write-Host "==================================================================" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Setup script exited with error code: $($wslProc.ExitCode)" -ForegroundColor Red
}

exit $wslProc.ExitCode
