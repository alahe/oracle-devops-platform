@echo off
REM ==============================================================================
REM Oracle DevOps Platform - Windows Native Launcher (setup.cmd)
REM Purpose: 1-Click launcher for Windows developers delegating to WSL2 environment.
REM Operates with 100% standard user privileges (0-Admin / No UAC required).
REM ==============================================================================
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo ==================================================================
echo   ORACLE DEVOPS PLATFORM - WINDOWS WSL2 LAUNCHER
echo ==================================================================

REM 1. Verify WSL availability
where wsl.exe >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Windows Subsystem for Linux (wsl.exe) was not found!
    echo.
    echo Please ensure WSL2 is installed on your Windows machine:
    echo    1. Open PowerShell as Administrator or request IT to run:
    echo       wsl --install --no-distribution
    echo    2. Install Ubuntu 22.04 or 24.04 from Microsoft Store or enterprise catalog.
    echo.
    pause
    exit /b 1
)

REM 2. Check if running from Windows NTFS mount (C:\... -> /mnt/c/...)
set "CURR_DRIVE=%CD:~0,2%"
if /i "%CURR_DRIVE%" NEQ "\\" (
    echo [WARNING] Detected execution from Windows drive path (%CD%).
    echo           Accessing files via WSL2 /mnt/c/ causes a 10x-50x I/O slowdown!
    echo.
    echo [RECOMMENDATION] For optimal performance (APEX, ORDS, database builds):
    echo    Clone and run this project inside the native WSL2 ext4 filesystem:
    echo       1. Open WSL terminal: wsl
    echo       2. cd ~
    echo       3. git clone ^<repo-url^> oracle-free-db-in-prod
    echo       4. cd oracle-free-db-in-prod ^&^& ./scripts/setup-all.sh %*
    echo.
    echo Continuing execution in current location...
    echo ==================================================================
)

REM 3. Check for dry-run flag
set "IS_DRYRUN=0"
for %%A in (%*) do (
    if /i "%%A"=="--dry-run" set "IS_DRYRUN=1"
    if /i "%%A"=="-d" set "IS_DRYRUN=1"
)

if "!IS_DRYRUN!"=="1" (
    echo [INFO] Dry-run mode detected. Delegating to diagnostic engine...
    echo [INFO] Command: ./scripts/test-windows-dryrun.sh %*
    echo ==================================================================
    echo.
    wsl.exe bash -lic "./scripts/test-windows-dryrun.sh %*"
    exit /b !ERRORLEVEL!
)

REM 4. Forward execution into WSL2
echo [INFO] Delegating execution to WSL2 Linux environment...
echo [INFO] Command: ./scripts/setup-all.sh %*
echo ==================================================================
echo.

wsl.exe bash -lic "./scripts/setup-all.sh %*"

set "EXIT_CODE=%ERRORLEVEL%"
if %EXIT_CODE% EQU 0 (
    echo.
    echo ==================================================================
    echo [SUCCESS] Environment setup completed successfully!
    echo           To trust SSL certificates in Windows browsers, run:
    echo           scripts\certs\trust-local-cert.cmd
    echo ==================================================================
) else (
    echo.
    echo [ERROR] Setup script exited with error code: %EXIT_CODE%
)

exit /b %EXIT_CODE%
