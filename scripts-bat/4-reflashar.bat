@echo off
chcp 65001 >nul
title positivo-t2040b-reset - 4 de 9 - Reflashar o tablet (10 min)
echo.
echo ============================================================
echo   positivo-t2040b-reset - 4 de 9 - Reflashar o tablet (10 min)
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\03-reflash.ps1"
echo.
echo ------------------------------------------------------------
pause
