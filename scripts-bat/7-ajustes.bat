@echo off
chcp 65001 >nul
title positivo-t2040b-reset - 7 de 9 - Ajustes de desempenho
echo.
echo ============================================================
echo   positivo-t2040b-reset - 7 de 9 - Ajustes de desempenho
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\06-ajustes-performance.ps1"
echo.
echo ------------------------------------------------------------
pause
