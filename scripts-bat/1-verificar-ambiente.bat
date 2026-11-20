@echo off
chcp 65001 >nul
title reset-t2040 - 1 de 9 - Verificar ambiente
echo.
echo ============================================================
echo   reset-t2040 - 1 de 9 - Verificar ambiente
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\00-verificar-ambiente.ps1"
echo.
echo ------------------------------------------------------------
pause
