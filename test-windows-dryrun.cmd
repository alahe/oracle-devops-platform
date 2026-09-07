@echo off
REM ==============================================================================
REM Oracle DevOps Platform - Enterprise Windows Dry-Run Launcher
REM Purpose: 1-Click launcher to verify Windows & WSL2 compatibility before setup.
REM Operates with 100% standard user privileges (0-Admin / No UAC required).
REM ==============================================================================
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo ==================================================================
echo   ORACLE DEVOPS PLATFORM - WINDOWS DRY-RUN DIAGNOSTIC LAUNCHER
echo ==================================================================

REM 1. Verify WSL availability
where wsl.exe >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Windows Subsystem for Linux (wsl.exe) was not found!
    echo.
    echo Please ensure WSL2 is installed on your Windows workstation:
    echo    1. Open PowerShell and run:
    echo       wsl --install --no-distribution
    echo    2. Install Ubuntu from Microsoft Store or enterprise Artifactory.
    echo.
    pause
    exit /b 1
)

REM 2. Forward execution to dry-run script inside WSL2
echo [INFO] Delegating diagnostic checks to WSL2 Linux environment...
echo [INFO] Command: ./tests/test-windows-dryrun.sh %*
echo.

wsl.exe bash -lic "if [ -f ./tests/test-windows-dryrun.sh ]; then ./tests/test-windows-dryrun.sh %*; else ./scripts/test-windows-dryrun.sh %*; fi"

set "EXIT_CODE=%ERRORLEVEL%"
echo.
echo ==================================================================
if %EXIT_CODE% EQU 0 (
    echo [INFO] Dry-run completed. If ready, run: setup.cmd
) else (
    echo [WARN] Dry-run detected issues. Review recommendations above.
)
echo ==================================================================
echo.

REM Pause so window stays open if double-clicked from Windows Explorer
pause
exit /b %EXIT_CODE%
