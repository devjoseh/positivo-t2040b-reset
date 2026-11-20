@echo off
chcp 65001 >nul
title positivo-t2040b-reset - 5 de 9 - Bloquear provisionamento
echo.
echo ============================================================
echo   positivo-t2040b-reset - 5 de 9 - Bloquear provisionamento
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\04-bloquear-provisionamento.ps1"
echo.
echo ------------------------------------------------------------
pause
