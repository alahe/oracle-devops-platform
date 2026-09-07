@echo off
REM ==============================================================================
REM Oracle DevOps Platform - Glossary Web Links Zero-Download Audit (Windows)
REM Operates with 100% standard user privileges (0-Admin / No UAC required).
REM Uses NUL virtual null device and in-memory HTTP HEAD requests.
REM ==============================================================================
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "WORKSPACE_DIR=%SCRIPT_DIR%..\.."

echo ==================================================================
echo   ORACLE DEVOPS PLATFORM - GLOSSARY WEB LINKS ZERO-DOWNLOAD AUDIT
echo   Environment: Windows Native (CMD/PowerShell)
echo   Null Device: NUL
echo ==================================================================

REM Check Python availability
where python.exe >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    python.exe "%WORKSPACE_DIR%\scripts\internal\check-glossary-links.py" %*
    exit /b %ERRORLEVEL%
)

where py.exe >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    py.exe -3 "%WORKSPACE_DIR%\scripts\internal\check-glossary-links.py" %*
    exit /b %ERRORLEVEL%
)

echo [INFO] Python not found in Windows PATH, delegating to WSL2...
where wsl.exe >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    wsl.exe bash -lic "./tests/unit/test-glossary-links.sh %*"
    exit /b %ERRORLEVEL%
)

echo [ERROR] Neither python.exe nor wsl.exe was found!
exit /b 1
