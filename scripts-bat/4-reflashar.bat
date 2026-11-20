@echo off
chcp 65001 >nul
title reset-t2040 - 4 de 9 - Reflashar o tablet (10 min)
echo.
echo ============================================================
echo   reset-t2040 - 4 de 9 - Reflashar o tablet (10 min)
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\03-reflash.ps1"
echo.
echo ------------------------------------------------------------
pause
