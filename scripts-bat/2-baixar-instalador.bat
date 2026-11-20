@echo off
chcp 65001 >nul
title reset-t2040 - 2 de 9 - Baixar instalador oficial (1,5 GB)
echo.
echo ============================================================
echo   reset-t2040 - 2 de 9 - Baixar instalador oficial (1,5 GB)
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\01-baixar-instalador.ps1"
echo.
echo ------------------------------------------------------------
pause
