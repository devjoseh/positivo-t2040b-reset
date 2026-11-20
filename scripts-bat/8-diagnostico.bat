@echo off
chcp 65001 >nul
title positivo-t2040b-reset - 8 de 9 - Diagnostico completo
echo.
echo ============================================================
echo   positivo-t2040b-reset - 8 de 9 - Diagnostico completo
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\07-diagnostico.ps1"
echo.
echo ------------------------------------------------------------
pause
