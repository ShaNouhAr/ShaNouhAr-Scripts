@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Vérifier si Chocolatey est installé
where choco >nul 2>nul
IF NOT %ERRORLEVEL% EQU 0 (
    echo Installation de Chocolatey...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex"
) ELSE (
    echo Mise à jour de Chocolatey...
    choco upgrade chocolatey -y --force
)

:: Installer ou mettre à jour Python via Chocolatey
echo Installation ou mise à jour de Python...
choco install python -y --force

:End
ENDLOCAL
