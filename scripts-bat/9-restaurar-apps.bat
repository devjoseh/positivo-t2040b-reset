@echo off
chcp 65001 >nul
title reset-t2040 - 9 de 9 - Restaurar aplicativos removidos
echo.
echo ============================================================
echo   reset-t2040 - 9 de 9 - Restaurar aplicativos removidos
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\99-restaurar-apps.ps1"
echo.
echo ------------------------------------------------------------
pause
