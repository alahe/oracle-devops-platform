@echo off
REM ============================================================================
REM Oracle DevOps Platform - Windows User Certificate Installer
REM Lisab kohaliku Dev Root CA Windowsi jooksva kasutaja usaldusväärsesse hoidlasse.
REM Toimib 100% tavakasutaja õigustes (0-Root / No Admin / No UAC prompt).
REM ============================================================================

setlocal
set "SCRIPT_DIR=%~dp0"
set "ROOT_DIR=%SCRIPT_DIR%.."
set "CERT_FILE=%ROOT_DIR%\config\certs\localCA.pem"

echo ==================================================================
echo   ORACLE DEVOPS PLATFORM - SERTIFIKAADI USALDAMINE (WINDOWS)
echo ==================================================================

if not exist "%CERT_FILE%" (
    echo [VIGA] Sertifikaati ei leitud asukohast:
    echo        %CERT_FILE%
    echo.
    echo Palun kaivita esmalt keskkonna seadistus: scripts\setup-all.sh
    echo voi sertifikaatide genereerija: scripts\internal\generate-local-certs.sh
    echo.
    pause
    exit /b 1
)

echo [INFO] Lisame sertifikaadi Windowsi jooksva kasutaja hoidlasse (CurrentUser)...
echo [INFO] Kasutame kasku: certutil -user -addstore Root "%CERT_FILE%"
echo.

certutil -user -addstore Root "%CERT_FILE%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==================================================================
    echo [EDUKAS] Sertifikaat 'Local Dev Root CA' on edukalt usaldatud!
    echo          Brauserid (Chrome, Edge) avavad nuud HTTPS lingid
    echo          (nt https://localhost:8448/ords/) ilma hoiatusteta!
    echo ==================================================================
) else (
    echo.
    echo [HOIATUS] certutil tagastas veakoodi: %ERRORLEVEL%
)

echo.
pause
