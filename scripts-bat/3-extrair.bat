@echo off
chcp 65001 >nul
title reset-t2040 - 3 de 9 - Extrair ROM e ferramentas
echo.
echo ============================================================
echo   reset-t2040 - 3 de 9 - Extrair ROM e ferramentas
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\02-extrair-payload.ps1"
echo.
echo ------------------------------------------------------------
pause
