@echo off
chcp 65001 >nul
title Codex Hub - Diagnostics
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Diagnose.ps1"
set "TASK_RESULT=%ERRORLEVEL%"
pause
exit /b %TASK_RESULT%
