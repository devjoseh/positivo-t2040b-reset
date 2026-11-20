@echo off
chcp 65001 >nul
title positivo-t2040b-reset - 6 de 9 - Remover aplicativos
echo.
echo ============================================================
echo   positivo-t2040b-reset - 6 de 9 - Remover aplicativos
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\05-remover-apps.ps1"
echo.
echo ------------------------------------------------------------
pause
