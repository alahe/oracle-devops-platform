@echo off
REM ============================================================================
REM Oracle DevOps Platform - Windows User Certificate Remover
REM Eemaldab kohaliku Dev Root CA Windowsi jooksva kasutaja hoidlast.
REM ============================================================================

echo ==================================================================
echo   ORACLE DEVOPS PLATFORM - SERTIFIKAADI EEMALDAMINE (WINDOWS)
echo ==================================================================

echo [INFO] Eemaldame sertifikaadi 'Local Dev Root CA' kasutaja hoidlast...
certutil -user -delstore Root "Local Dev Root CA"

if %ERRORLEVEL% EQU 0 (
    echo [EDUKAS] Sertifikaat on edukalt eemaldatud.
) else (
    echo [INFO] Sertifikaati ei leitud voi see oli juba eemaldatud.
)

echo.
pause
