@echo off
chcp 65001 >nul
title positivo-t2040b-reset - 2 de 9 - Baixar instalador oficial (1,5 GB)
echo.
echo ============================================================
echo   positivo-t2040b-reset - 2 de 9 - Baixar instalador oficial (1,5 GB)
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\01-baixar-instalador.ps1"
echo.
echo ------------------------------------------------------------
pause
