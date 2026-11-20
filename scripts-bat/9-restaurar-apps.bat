@echo off
chcp 65001 >nul
title positivo-t2040b-reset - 9 de 9 - Restaurar aplicativos removidos
echo.
echo ============================================================
echo   positivo-t2040b-reset - 9 de 9 - Restaurar aplicativos removidos
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\99-restaurar-apps.ps1"
echo.
echo ------------------------------------------------------------
pause
