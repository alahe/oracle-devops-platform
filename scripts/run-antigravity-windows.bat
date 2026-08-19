@echo off
REM ============================================================================
REM Google Antigravity & Web IDE Windows Enterprise Podman Batch Launcher
REM Double-click this .bat file on Windows to launch Antigravity inside Podman.
REM ============================================================================

echo ==================================================================
echo 🚀 GOOGLE ANTIGRAVITY WINDOWS ENTERPRISE PODMAN LAUNCHER
echo ==================================================================

powershell -ExecutionPolicy Bypass -File "%~dp0run-antigravity-windows.ps1"

pause
