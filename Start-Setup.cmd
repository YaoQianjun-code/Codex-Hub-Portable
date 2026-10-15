@echo off
chcp 65001 >nul
title Codex Hub Portable v4.3 Setup
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Setup-CodexHub.ps1"
set "TASK_RESULT=%ERRORLEVEL%"
if not "%TASK_RESULT%"=="0" echo [FAILED] Setup did not finish. Read the error above and run again.
pause
exit /b %TASK_RESULT%
